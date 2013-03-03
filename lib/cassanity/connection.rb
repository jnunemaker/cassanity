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
      @executor.call({
        command: :keyspaces,
        transformer_arguments: {
          executor: @executor,
        },
      })
    end

    # Public: Get a keyspace instance
    #
    # name_or_args - The String name of the keyspace or a Hash which has a name
    #                key and possibly other arguments.
    # args - The Hash of arguments to use for Keyspace initialization.
    #        (optional, default: {}). :executor is always included.
    #
    # Returns a Cassanity::Keyspace instance.
    def keyspace(name_or_args, args = {})
      keyspace_args = if name_or_args.is_a?(Hash)
        name_or_args.merge(args)
      else
        args.merge(name: name_or_args)
      end

      Keyspace.new(keyspace_args.merge(executor: executor))
    end

    alias_method :[], :keyspace

    # Public
    def inspect
      attributes = [
        "executor=#{@executor.inspect}",
      ]
      "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
    end
  end
end
