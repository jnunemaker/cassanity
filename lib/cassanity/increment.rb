module Cassanity
  def self.Increment(*args)
    Increment.new(*args)
  end

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

    def eql?(other)
      self.class.eql?(other.class) && value == other.value
    end

    alias_method :==, :eql?
  end
end
