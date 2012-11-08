module Cassanity
  class Schema
    # Internal
    attr_reader :primary_keys

    # Internal
    alias_method :primary_key, :primary_keys

    # Internal
    attr_reader :columns

    # Internal
    attr_reader :with

    # Public: Initializes a Schema.
    #
    # args - The Hash of arguments.
    #        :primary_key - The String or Symbol key or Array of String/Symbol
    #                       keys to use as primary key.
    #        :columns - The Hash of columns where the name is the column name
    #                   and the value is the column type.
    #        :with - The Hash of options for the WITH clause.
    # Raises KeyError if missing required argument key.
    # Raises ArgumentError if primary key is not included in the columns.
    def initialize(args = {})
      @primary_keys = Array(args.fetch(:primary_key))
      @columns = args.fetch(:columns)

      ensure_primary_keys_are_columns

      @with = args[:with] || {}
      @composite_primary_key = @primary_keys.size > 1
    end

    # Public
    def composite_primary_key?
      @composite_primary_key == true
    end

    # Public: Returns an array of the column names
    def column_names
      @column_names ||= @columns.keys
    end

    # Public: Returns an array of the column types
    def column_types
      @column_types ||= @columns.values
    end

    # Private
    def ensure_primary_keys_are_columns
      shared_columns = column_names & @primary_keys

      if shared_columns != @primary_keys
        missing_columns = @primary_keys - shared_columns
        raise ArgumentError, "The following primary keys were not defined as a column: #{missing_columns.join(', ')}"
      end
    end
  end
end
