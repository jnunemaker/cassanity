require 'cassanity/operator'

module Cassanity
  module Operators
    def self.Gt(*args)
      Gt.new(*args)
    end

    class Gt < Operator
      def initialize(value)
        super(:>, value)
      end
    end
  end
end
