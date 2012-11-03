module Cassanity
  class ColumnFamily
    # Public
    attr_reader :name

    # Public
    attr_reader :keyspace

    # Private
    attr_reader :executor

    # Public: Initializes a ColumnFamily.
    #
    # args - The Hash of arguments (default: {}).
    #        :name - The String name of the column family.
    #        :keyspace - The Cassanity::Keyspace the column family is in.
    #        :executor - What will execute the queries (optional).
    #                    Must respond to `call`.
    #
    def initialize(args = {})
      @name = args.fetch(:name)
      @keyspace = args.fetch(:keyspace)
      @executor = args.fetch(:executor) { @keyspace.executor }
    end

    # Public: Truncates the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Returns whatever is returned by executor.
    def truncate(args = {})
      @executor.call({
        command: :column_family_truncate,
        arguments: args.merge({
          name: @name,
        }),
      })
    end

    # Public: Drops the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Returns whatever is returned by executor.
    def drop(args = {})
      @executor.call({
        command: :column_family_drop,
        arguments: args.merge({
          name: @name,
        }),
      })
    end

    # Public: Makes it possible to insert data into the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Returns whatever is returned by executor.
    def insert(args = {})
      @executor.call({
        command: :column_family_insert,
        arguments: args.merge({
          name: @name,
        }),
      })
    end

    # Public: Makes it possible to update data in the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Returns whatever is returned by executor.
    def update(args = {})
      @executor.call({
        command: :column_family_update,
        arguments: args.merge({
          name: @name,
        }),
      })
    end

    # Public: Makes it possible to delete data from the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :name is always included.
    #
    # Returns whatever is returned by executor.
    def delete(args = {})
      @executor.call({
        command: :column_family_delete,
        arguments: args.merge({
          name: @name,
        }),
      })
    end
  end
end
