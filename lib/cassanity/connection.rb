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

    # Public: Group multiple statements into a batch.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}).
    #
    # Examples
    #
    #   batch({
    #     modifications: [
    #       [:insert, name: 'apps', data: {id: '1', name: 'github'}],
    #       [:insert, name: 'apps', data: {id: '2', name: 'gist'}],
    #       [:update, name: 'apps', set: {name: 'github.com'}, where: {id: '1'}],
    #       [:delete, name: 'apps', where: {id: '2'}],
    #     ]
    #   })
    #
    # Returns whatever is returned by executor.
    def batch(args = {})
      @executor.call({
        command: :batch,
        arguments: args,
      })
    end

    # Public: Get all keyspaces.
    #
    # Returns Array of Cassanity::Keyspace instances.
    def keyspaces
      rows = @executor.call({
        command: :keyspaces,
      })

      rows.map { |row|
        Keyspace.new({
          name: row['name'],
          executor: @executor,
        })
      }
    end

    # Public: Get a keyspace instance
    #
    # name - The String name of the keyspace.
    #
    # Returns a Cassanity::Keyspace instance.
    def keyspace(name_or_args, args = {})
      keyspace_args = if name_or_args.is_a?(Hash)
        args.merge(name_or_args).merge({
          executor: @executor,
        })
      else
        name = name_or_args
        args.merge({
          name: name,
          executor: @executor,
        })
      end

      Keyspace.new(keyspace_args)
    end

    alias_method :[], :keyspace
  end
end
