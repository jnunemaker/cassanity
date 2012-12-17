require 'cassanity/operator'

module Cassanity
  module Operators
    def self.Lte(*args)
      Lte.new(*args)
    end

    class Lte < Operator
      def initialize(value)
        super(:<=, value)
      end
    end
  end
end
