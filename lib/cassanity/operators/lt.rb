require 'cassanity/operator'

module Cassanity
  module Operators
    def self.Lt(*args)
      Lt.new(*args)
    end

    class Lt < Operator
      def initialize(value)
        super(:<, value)
      end
    end
  end
end
