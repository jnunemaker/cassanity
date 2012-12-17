require 'cassanity/operator'

module Cassanity
  module Operators
    class Gt < Operator
      def initialize(value)
        super(:>, value)
      end
    end
  end
end
