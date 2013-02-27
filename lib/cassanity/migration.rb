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
      basename = File.basename(path, '.rb')
      version, name = basename.split('_', 2)
      new(version, name)
    end

    # Public: Converts a hash to migration instance.
    #
    # hash - The Hash for that has migration details.
    #
    # Examples
    #
    #   migration = Cassanity::Migration.from_hash({version: 1234, name: 'foo'})
    #   puts migration.version # 1234
    #   puts migration.name # "foo"
    #
    # Returns Cassanity::Migration instance.
    def self.from_hash(hash)
      new(hash['version'], hash['name'])
    end

    # Public: The version of the migration.
    attr_reader :version

    # Public: The name of the migration.
    attr_reader :name

    def initialize(version, name)
      raise ArgumentError, "version cannot be nil" if version.nil?
      raise ArgumentError, "name cannot be nil" if name.nil?

      @version = version.to_i
      @name = name
    end

    # Public: Runs a migration operation for a migrator.
    def run(migrator, operation)
      case operation
      when :up
        up
        migrator.migrated(self)
      else
        raise MigrationOperationNotSupported,
          "#{operation.inspect} is not a supported migration operation"
      end
    end

    def up
      # override in subclass
    end

    def down
      # override in subclass
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        version == other.version &&
        name == other.name
    end
    alias_method :==, :eql?
  end
end
