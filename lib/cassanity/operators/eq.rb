require 'cassanity/operator'

module Cassanity
  module Operators
    class Eq < Operator
      def initialize(value)
        super :"=", value
      end
    end
  end
end
