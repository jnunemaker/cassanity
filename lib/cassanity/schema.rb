module Cassanity
  class Schema
    # Internal
    attr_reader :primary_key

    # Internal
    attr_reader :columns

    # Internal
    attr_reader :with

    def initialize(args = {})
      @primary_key = args.fetch(:primary_key)
      @columns = args.fetch(:columns)
      @with = args[:with] || {}
    end
  end
end
