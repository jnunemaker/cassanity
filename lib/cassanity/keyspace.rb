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

    # Public: Creates a column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Examples
    #
    #   create_column_family({
    #     name: 'apps',
    #     primary_key: :id,
    #     columns: {
    #       id: :timeuuid,
    #       name: :text,
    #     }
    #   })
    #
    # Returns whatever is returned by executor.
    def create_column_family(args = {})
      @executor.call({
        command: :column_family_create,
        arguments: args.merge({
          keyspace_name: @name,
        }),
      })
    end
    alias_method :create_table, :create_column_family

    # Public: Get a column family instance
    #
    # name - The String name of the column family.
    #
    # Returns a Cassanity::ColumnFamily instance.
    def column_family(name)
      ColumnFamily.new({
        name: name,
        keyspace: self,
      })
    end
    alias_method :table, :column_family
    alias_method :[], :column_family
  end
end
