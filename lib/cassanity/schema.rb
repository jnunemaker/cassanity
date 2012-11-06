module Cassanity
  class Schema
    # Internal
    attr_reader :primary_key

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
    def initialize(args = {})
      @primary_key = args.fetch(:primary_key)
      @columns = args.fetch(:columns)
      @with = args[:with] || {}
    end
  end
end
