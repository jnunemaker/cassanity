module Cassanity
  def self.Operator(*args)
    Operator.new(*args)
  end

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

    def eql?(other)
      self.class.eql?(other.class) &&
        value == other.value &&
        symbol == other.symbol
    end

    alias_method :==, :eql?

    # Public
    def inspect
      attributes = [
        "symbol=#{symbol.inspect}",
        "value=#{value.inspect}",
      ]
      "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
    end
  end
end
