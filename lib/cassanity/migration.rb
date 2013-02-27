module Cassanity
  class Migration
    def self.from_path(path)
      basename = File.basename(path, '.rb')
      version, name = basename.split('_', 2)
      new(version, name)
    end

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
