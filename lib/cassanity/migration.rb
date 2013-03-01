require 'pathname'

module Cassanity
  class Migration
    # Private: The Cassanity::Keyspace instance.
    attr_reader :keyspace

    def initialize(keyspace)
      @keyspace = keyspace
    end

    def up
    end

    def down
    end
  end
end
