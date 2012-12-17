module Cassanity
  class Operator
    # Internal
    attr_reader :symbol

    # Internal
    attr_reader :value

    # Public: Returns an operator instance
    def initialize(symbol, value)
      @symbol = symbol
      @value = value
    end
  end
end
