require 'cassanity/operator'

module Cassanity
  module Operators
    class Lt < Operator
      def initialize(value)
        super(:<, value)
      end
    end
  end
end
