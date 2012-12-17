module Cassanity
  def self.Decrement(*args)
    Decrement.new(*args)
  end

  class Decrement
    # Internal
    attr_reader :symbol

    # Internal
    attr_reader :value

    # Public: Returns an decrement instance
    def initialize(value = 1)
      raise ArgumentError.new("value cannot be nil") if value.nil?

      @symbol = :-
      @value = value
    end

    def eql?(other)
      self.class.eql?(other.class) && value == other.value
    end

    alias_method :==, :eql?
  end
end
