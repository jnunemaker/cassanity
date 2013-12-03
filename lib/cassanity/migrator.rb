require 'logger'
require 'pathname'
require 'cassanity/migration_proxy'
require 'cassanity/migration'

module Cassanity
  class Migrator
    SupportedDirections = [:up, :down]

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

    # Public: Runs all pending migrations in order.
    def migrate
      run_migrations pending_migrations, :up
    end

    # Public: Migrates to a version using a direction.
    #
    # version - The String or Integer version to migrate to.
    # direction - The String or Symbol direction you would like to migrate.
    def migrate_to(version, direction = :up)
      version = version.to_i
      direction = direction.to_sym
      assert_valid_direction(direction)

      migrations = case direction
      when :up
        pending_migrations.select { |migration| migration.version <= version }
      when :down
        performed_migrations.select { |migration| migration.version > version }
      else
        []
      end

      run_migrations migrations, direction
    end

    # Public: Marks a migration as migrated.
    def migrated_up(migration)
      column_family.insert({
        data: {
          version: migration.version.to_s,
          name: migration.name,
          migrated_at: Time.now.utc,
        },
      })
    end

    # Public: Marks a migration as not run.
    def migrated_down(migration)
      column_family.delete({
        where: {
          version: migration.version.to_s,
          name: migration.name,
        },
      })
    end

    # Public: An array of all migrations.
    def migrations
      @migrations ||= begin
        paths = Dir["#{migrations_path}/*.rb"]
        migrations = paths.map { |path| MigrationProxy.new(path) }
        migrations.sort
      end
    end

    # Public: An array of the migrations that have been performed.
    def performed_migrations
      rows = column_family.select
      rows.map { |row|
        path = migrations_path.join("#{row['version']}_#{row['name']}.rb")
        MigrationProxy.new(path)
      }.sort
    end

    # Public: An array of the migrations that have not been performed.
    def pending_migrations
      (migrations - performed_migrations).sort
    end

    # Internal: Log a message.
    def log(message)
      @logger.info message
    end

    # Private
    def run_migrations(migrations, direction)
      migrations = migrations.sort

      case direction
      when :up
        migrations.each do |migration|
          migration.up(self)
          migrated_up(migration)
        end
      when :down
        migrations = migrations.reverse
        migrations.each do |migration|
          migration.down(self)
          migrated_down(migration)
        end
      end

      {performed: migrations}
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

    def assert_valid_direction(direction)
      unless SupportedDirections.include?(direction)
        raise ArgumentError, "#{direction.inspect} is not a valid migration direction"
      end
    end
  end
end
