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

    # Public: Create a column family.
    #
    # column_family_name - The String or Symbol name of the column family.
    # args - The Hash of arguments. See ColumnFamily#create for available args.
    #
    # Returns nothing.
    def create_column_family(column_family_name, schema)
      keyspace.column_family(column_family_name, schema: schema).create
    end
    alias_method :add_column_family, :create_column_family
    alias_method :create_table, :create_column_family
    alias_method :add_table, :create_column_family

    # Public: Drop a column family.
    #
    # column_family_name - The String or Symbol name of the column family.
    #
    # Returns nothing.
    def drop_column_family(column_family_name)
      keyspace[column_family_name].drop
    end
    alias_method :drop_table, :drop_column_family

    # Public: Add a column to a column family.
    #
    # column_family_name - The String or Symbol name of the column family.
    # column_name - The String or Symbol name of the column to index.
    # type - The String or Symbol CQL data type for the column.
    #
    # Returns nothing.
    def add_column(column_family_name, column_name, type)
      keyspace[column_family_name].alter(add: {column_name => type})
    end
    alias_method :create_column, :add_column

    # Public: Drop a column from a column family.
    #
    # column_family_name - The String or Symbol name of the column family.
    # column_name - The String or Symbol name of the column to index.
    #
    # Returns nothing.
    def drop_column(column_family_name, column_name)
      keyspace[column_family_name].alter(drop: column_name)
    end

    # Public: Alter a column family.
    #
    # column_family_name - The String or Symbol name of the column family.
    # args - The Hash of arguments. See ColumnFamily#alter for available args.
    #
    # Returns nothing.
    def alter_column_family(column_family_name, args = {})
      keyspace[column_family_name].alter(args)
    end
    alias_method :alter_table, :alter_column_family

    # Public: Create an index on a column for a column family.
    #
    # column_family_name - The String or Symbol name of the column family.
    # column_name - The String or Symbol name of the column to index.
    # options - The Hash of options.
    #           :name - The String or Symbol name of the index
    #                   (defaults to column_name).
    #
    # Returns nothing.
    def add_index(column_family_name, column_name, options = {})
      index_args = {column_name: column_name}
      index_args[:name] = options[:name] if options.key?(:name)

      keyspace[column_family_name].create_index(index_args)
    end
    alias_method :create_index, :add_index

    # Public: Drop an index by name for a column family.
    #
    # column_family_name - The String or Symbol name of the column family.
    # name - The String or Symbol name of the index.
    #
    # Returns nothing.
    def drop_index(column_family_name, index_name)
      keyspace[column_family_name].drop_index(name: index_name)
    end
  end
end
