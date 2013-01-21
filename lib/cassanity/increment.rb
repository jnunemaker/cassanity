module Cassanity
  def self.Increment(*args)
    Increment.new(*args)
  end

  class Increment < Operator
    # Public: Returns an increment instance
    def initialize(value = 1)
      raise ArgumentError.new("value cannot be nil") if value.nil?

      super :+, value
    end
  end
end
