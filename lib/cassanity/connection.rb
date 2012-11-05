require 'cassanity/keyspace'

module Cassanity
  class Connection
    # Internal
    attr_reader :executor

    # Public: Initializes a connection
    #
    # args - The Hash of arguments (default: {}).
    #        :executor - What will execute the CQL statements.
    #                    Must respond to `call`.
    def initialize(args = {})
      @executor = args.fetch(:executor)
    end

    # Public: Get all keyspaces.
    #
    # Returns Array of Cassanity::Keyspace instances.
    def keyspaces
      keyspaces = []

      result = @executor.call({
        command: :keyspaces,
      })

      result.fetch_hash do |row|
        keyspaces << row
      end

      keyspaces.map { |row|
        Keyspace.new({
          name: row['name'],
          executor: @executor,
        })
      }
    end

    # Public: Find out if a keyspace exists or not
    #
    # name - The String name of the keyspace
    #
    # Returns true if keyspace exists else false.
    def keyspace?(name)
      keyspaces.map(&:name).include?(name)
    end

    # Public: Get a keyspace instance
    #
    # name - The String name of the keyspace.
    #
    # Returns a Cassanity::Keyspace instance.
    def keyspace(name, args = {})
      keyspace_args = args.merge({
        name: name,
        executor: @executor,
      })

      Keyspace.new(keyspace_args)
    end

    alias_method :[], :keyspace
  end
end
