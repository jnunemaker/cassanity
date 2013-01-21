module Cassanity
  def self.Decrement(*args)
    Decrement.new(*args)
  end

  class Decrement < Operator
    # Public: Returns an decrement instance
    def initialize(value = 1)
      raise ArgumentError.new("value cannot be nil") if value.nil?

      super :-, value
    end
  end
end
