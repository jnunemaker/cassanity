require 'pathname'
require 'cassanity/migration_proxy'
require 'cassanity/migration'

module Cassanity
  class Migrator
    # Public: The keyspace all migrations apply to.
    attr_reader :keyspace

    # Public: The path to all the migrations.
    attr_reader :migrations_path

    def initialize(keyspace, migrations_path)
      @keyspace = keyspace
      @migrations_path = Pathname(migrations_path)
    end

    # Public: Migrates all the migrations that have not run in version order.
    def migrate
      migrations_to_run = not_ran_migrations
      run_migrations migrations_to_run, :up

      {
        ran_migrations: migrations_to_run,
      }
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

    # Private
    def migrations_to_run(version, direction)
      send("#{direction}_migrations_to_run", version)
    end

    # Private
    def up_migrations_to_run(version)
      version = version.to_i
      not_ran_migrations.select { |migration| migration.version <= version }
    end

    # Private
    def down_migrations_to_run(version)
      version = version.to_i
      ran_migrations.select { |migration| migration.version > version }
    end

    # Private
    def run_migrations(migrations, direction)
      migrations.each { |migration|
        migration.run(self, direction)
      }
    end

    # Private
    def migrations
      @migrations ||= begin
        paths = Dir["#{migrations_path}/*.rb"]
        sort_by_version paths.map { |path| MigrationProxy.new(path) }
      end
    end

    def sort_by_version(migrations)
      migrations.sort { |a, b| a.version <=> b.version }
    end

    # Private
    def ran_migrations
      rows = column_family.select
      sort_by_version rows.map { |row|
        path = migrations_path.join("#{row['version']}_#{row['name']}.rb")
        MigrationProxy.new(path)
      }
    end

    # Private
    def not_ran_migrations
      excluded = ran_migrations
      migrations.reject { |migration| excluded.include?(migration) }
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
  end
end
