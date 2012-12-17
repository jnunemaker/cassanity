require 'cassanity/operator'

module Cassanity
  module Operators
    def self.Eq(*args)
      Eq.new(*args)
    end

    class Eq < Operator
      def initialize(value)
        super :"=", value
      end
    end
  end
end
