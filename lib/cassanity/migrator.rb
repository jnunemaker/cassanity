require 'logger'
require 'pathname'
require 'cassanity/migration_proxy'
require 'cassanity/migration'

module Cassanity
  class Migrator
    # Public: The keyspace all migrations apply to.
    attr_reader :keyspace

    # Public: The path to all the migrations.
    attr_reader :migrations_path

    # Public: Where to spit all the logging related to migrations.
    attr_reader :logger

    def initialize(keyspace, migrations_path, options = {})
      @keyspace = keyspace
      @migrations_path = Pathname(migrations_path)
      @logger = options[:logger] || default_logger
    end

    # Public: Migrates all the migrations that have not run in version order.
    def migrate
      pending = pending_migrations
      run_migrations pending, :up
      {performed: pending}
    end

    # Public: Migrates to a version using a direction.
    def migrate_to(version, direction = :up)
      migrations_to_run = migrations_to_run(version, direction)
      run_migrations migrations_to_run, direction
    end

    # Public: Marks a migration as migrated.
    def migrated(migration)
      column_family.insert({
        data: {
          version: migration.version,
          name: migration.name,
          migrated_at: Time.now.utc,
        },
      })
    end

    # Public: Marks a migration as not run.
    def unmigrated(migration)
      column_family.delete({
        where: {
          version: migration.version,
          name: migration.name,
        },
      })
    end

    # Public: An array of all migrations.
    def migrations
      @migrations ||= begin
        paths = Dir["#{migrations_path}/*.rb"]
        sorted_migrations paths.map { |path| MigrationProxy.new(path) }
      end
    end

    # Public: An array of the migrations that have been performed.
    def performed_migrations
      rows = column_family.select
      sorted_migrations rows.map { |row|
        path = migrations_path.join("#{row['version']}_#{row['name']}.rb")
        MigrationProxy.new(path)
      }
    end

    # Public: An array of the migrations that have not been performed.
    def pending_migrations
      sorted_migrations migrations - performed_migrations
    end

    # Private
    def migrations_to_run(version, direction)
      version = version.to_i

      case direction
      when :up
        sorted_migrations pending_migrations.select { |migration|
          migration.version <= version
        }
      when :down
        sorted_migrations performed_migrations.select { |migration|
          migration.version > version
        }
      end
    end

    # Internal: Log a message.
    def log(message)
      @logger.info message
    end

    # Private
    def run_migrations(migrations, direction)
      migrations.each { |migration|
        migration.run(self, direction)
      }
    end

    # Private: Returns migrations sorted correctly.
    def sorted_migrations(migrations)
      migrations.sort { |a, b| a.version <=> b.version }
    end

    # Private: The column family storing all
    # migration information.
    def column_family
      @column_family ||= begin
        column_family = keyspace.column_family({
          name: :migrations,
          schema: {
            primary_key: [:version, :name],
            columns: {
              version: :text,
              name: :text,
              migrated_at: :timestamp,
            },
          },
        })
        column_family.create unless column_family.exists?
        column_family
      end
    end

    # Private
    def default_logger
      logger = Logger.new(STDOUT)
      logger.formatter = proc { |_, _, _, msg| "#{msg}\n" }
      logger
    end
  end
end
