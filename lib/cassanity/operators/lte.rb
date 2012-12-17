require 'cassanity/operator'

module Cassanity
  module Operators
    class Lte < Operator
      def initialize(value)
        super(:<=, value)
      end
    end
  end
end
