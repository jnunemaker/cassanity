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
      ensure_column_family_exists

      migrations_from_path.each do |migration|
        migration.run(self, :up)
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

    def migrations_from_path
      paths = Dir["#{migrations_path}/*.rb"]
      migrations = paths.map { |path|
        Migration.from_path(path)
      }
      Migration::Collection.new(migrations)
    end

    def migrations_from_column_family
      rows = column_family.select
      migrations = rows.map { |row| Migration.from_hash(row) }
      Migration::Collection.new(migrations)
    end

    # Private: The column family storing all
    # migration information.
    def column_family
      @column_family ||= keyspace.column_family({
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
    end

    # Private: Ensures that the column family exists.
    def ensure_column_family_exists
      column_family.create unless column_family.exists?
    end
  end
end
