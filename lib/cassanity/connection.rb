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

    # Public: Creates a keyspace
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Examples
    #
    #   create_keyspace(name: 'analytics')
    #   create_keyspace({
    #     name: 'analytics',
    #     strategy_class: 'NetworkTopologyStrategy',
    #     strategy_options: {
    #       dc1: 1,
    #       dc2: 3,
    #     }
    #   })
    #
    # Returns whatever is returned by executor.
    def create_keyspace(args = {})
      @executor.call({
        command: :keyspace_create,
        arguments: args,
      })
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
    def keyspace(name)
      Keyspace.new({
        name: name,
        executor: @executor,
      })
    end

    alias_method :[], :keyspace
  end
end
