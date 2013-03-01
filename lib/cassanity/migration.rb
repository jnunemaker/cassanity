require 'pathname'

module Cassanity
  class Migration
    # Public: Converts a path to migration instance.
    #
    # path - The String or Pathname path for the migration.
    #
    # Examples
    #
    #   migration = Cassanity::Migration.from_path('/db/migrations/1234_foo.rb')
    #   puts migration.version # 1234
    #   puts migration.name # "foo"
    #
    # Returns Cassanity::Migration instance.
    def self.from_path(path)
      new(path)
    end

    # Public: The full path to the migration on disk.
    attr_reader :path

    # Public: The version of the migration.
    attr_reader :version

    # Public: The name of the migration.
    attr_reader :name

    # Private: The Cassanity::Keyspace instance.
    attr_reader :keyspace

    def initialize(path)
      raise ArgumentError, "path cannot be nil" if path.nil?

      basename = File.basename(path, '.rb')
      version, name = basename.split('_', 2)

      raise ArgumentError, "version cannot be nil" if version.nil?
      raise ArgumentError, "name cannot be nil" if name.nil?

      @path = Pathname(path)
      @version = version.to_i
      @name = name
      @keyspace = nil
    end

    # Public: Runs a migration operation for a migrator on a keyspace.
    def run(migrator, operation)
      @keyspace = migrator.keyspace
      case operation
      when :up
        up
        migrator.migrated(self)
      when :down
        down
        migrator.unmigrated(self)
      else
        raise MigrationOperationNotSupported,
          "#{operation.inspect} is not a supported migration operation"
      end
    ensure
      @keyspace = nil
    end

    def up
      # override in subclass
    end

    def down
      # override in subclass
    end

    def eql?(other)
      self.class.eql?(other.class) && path == other.path
    end
    alias_method :==, :eql?
  end
end
