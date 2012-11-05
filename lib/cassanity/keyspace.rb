require 'cassanity/column_family'

module Cassanity
  class Keyspace
    # Public
    attr_reader :name

    # Internal
    attr_reader :executor

    # Public: Initializes a Keyspace.
    #
    # args - The Hash of arguments (default: {}).
    #        :name - The String name of the keyspace.
    #        :executor - What will execute the queries. Must respond to `call`.
    #
    def initialize(args = {})
      @name = args.fetch(:name)
      @executor = args.fetch(:executor)
    end

    # Public: Uses a keyspace
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Examples
    #
    #   use # you shouldn't really ever need more than this
    #
    # Returns whatever is returned by executor.
    def use(args = {})
      @executor.call({
        command: :keyspace_use,
        arguments: args.merge({
          name: @name,
        }),
      })
    end

    # Public: Drops a keyspace
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Examples
    #
    #   drop # you shouldn't really ever need more than this
    #
    # Returns whatever is returned by executor.
    def drop(args = {})
      @executor.call({
        command: :keyspace_drop,
        arguments: args.merge({
          name: @name,
        }),
      })
    end

    # Public: Get a column family instance
    #
    # name - The String name of the column family.
    # args - The Hash of arguments to use for ColumnFamily initialization
    #        (optional, default: {}).
    #
    # Returns a Cassanity::ColumnFamily instance.
    def column_family(name, args = {})
      column_family_args = args.merge({
        name: name,
        keyspace: self,
      })

      ColumnFamily.new(column_family_args)
    end
    alias_method :table, :column_family
    alias_method :[], :column_family
  end
end
