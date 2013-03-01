require 'forwardable'

module Cassanity
  class Migration
    extend Forwardable

    # Private: The migrator that is running the migration.
    attr_reader :migrator

    # Private: Delegates keyspace to migrator.
    def_delegator :@migrator, :keyspace

    # Public: Get new instance of a migration.
    #
    # migrator - The Cassanity::Migrator instance that is running the show.
    def initialize(migrator)
      @migrator = migrator
    end

    # Public: Override in subclass.
    def up
    end

    # Public: Override in subclass.
    def down
    end
  end
end
