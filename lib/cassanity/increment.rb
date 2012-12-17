module Cassanity
  class Increment
    # Internal
    attr_reader :symbol

    # Internal
    attr_reader :value

    # Public: Returns an increment instance
    def initialize(value = 1)
      raise ArgumentError.new("value cannot be nil") if value.nil?

      @symbol = :+
      @value = value
    end
  end
end
