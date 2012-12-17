require 'cassanity/operator'

module Cassanity
  module Operators
    def self.Gte(*args)
      Gte.new(*args)
    end

    class Gte < Operator
      def initialize(value)
        super(:>=, value)
      end
    end
  end
end
