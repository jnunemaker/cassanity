require 'cassanity/operator'

module Cassanity
  module Operators
    class Gte < Operator
      def initialize(value)
        super(:>=, value)
      end
    end
  end
end
