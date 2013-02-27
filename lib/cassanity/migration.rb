module Cassanity
  class Migration
    # Public: The name of the migration.
    attr_reader :name

    # Public: The version of the migration.
    attr_reader :version

    def initialize(name, version)
      @name = name
      @version = version
    end

    def up
      # override in subclass
    end

    def down
      # override in subclass
    end
  end
end
