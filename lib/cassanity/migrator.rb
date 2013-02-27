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

    def migrate
      migrations_to_run = migrations.without(ran_migrations)
      migrations_to_run.each { |migration| migration.run(self, :up) }

      {
        migrations: migrations,
        ran_migrations: migrations_to_run
      }
    end

    def migrate_to(version, direction = :up)
      version = version.to_i

      case direction
      when :up
        not_ran_migrations = migrations.without(ran_migrations)
        migrations_to_run = not_ran_migrations.delete_if { |migration|
          migration.version > version
        }
        migrations_to_run.each { |migration| migration.run(self, :up) }
      when :down
        migrations_to_run = ran_migrations.delete_if { |migration|
          migration.version <= version
        }
        migrations_to_run.each { |migration| migration.run(self, :down) }
      end
    end

    # Marks a migration as migrated.
    def migrated(migration)
      column_family.insert({
        data: {
          version: migration.version,
          name: migration.name,
          migrated_at: Time.now.utc,
        },
      })
    end

    def unmigrated(migration)
      column_family.delete({
        where: {
          version: migration.version,
          name: migration.name,
        },
      })
    end

    # Private
    def migrations
      @migrations ||= Migration::Collection.from_path(migrations_path)
    end

    # Private
    def ran_migrations
      Migration::Collection.from_column_family(column_family)
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
