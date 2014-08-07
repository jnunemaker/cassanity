require 'set'

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
    #
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
      unless primary_keys_are_defined_as_columns?
        raise ArgumentError, "Not all primary keys (#{primary_keys.inspect}) were defined as columns (#{column_names.inspect})"
      end
    end

    # Private
    def primary_keys_are_defined_as_columns?
      flattened_primary_keys = @primary_keys.flatten
      shared_columns = column_names & flattened_primary_keys
      shared_columns.to_set == flattened_primary_keys.to_set
    end

    # Public
    def inspect
      attributes = [
        "primary_keys=#{primary_keys.inspect}",
        "columns=#{columns.inspect}",
        "with=#{with.inspect}",
      ]
      "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
    end

    # Public: Is this schema equal to another object.
    def eql?(other)
      self.class.eql?(other.class) &&
        @primary_keys == other.primary_keys &&
        @columns == other.columns &&
        @with == other.with
    end

    alias_method :==, :eql?
  end
end
