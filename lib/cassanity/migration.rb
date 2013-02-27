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
  end
end
