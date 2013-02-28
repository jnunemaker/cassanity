require 'pathname'
require 'cassanity/migration'
require 'cassanity/migration/collection'

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
      case direction
      when :up
        up_migrations_to_run(version)
      when :down
        down_migrations_to_run(version)
      end
    end

    # Private
    def up_migrations_to_run(version)
      not_ran_migrations.up_to(version)
    end

    # Private
    def down_migrations_to_run(version)
      ran_migrations.down_to(version)
    end

    # Private
    def run_migrations(migrations, direction)
      migrations.each { |migration|
        migration.run(self, direction)
      }
    end

    # Private
    def migrations
      @migrations ||= Migration::Collection.from_path(migrations_path)
    end

    # Private
    def ran_migrations
      Migration::Collection.from_array_of_hashes(column_family.select)
    end

    # Private
    def not_ran_migrations
      migrations.without(ran_migrations)
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
