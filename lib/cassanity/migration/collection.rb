require 'delegate'

module Cassanity
  class Migration
    class Collection < SimpleDelegator
      def initialize(collection)
        sorted = collection.sort do |a, b|
          a.version <=> b.version
        end

        super sorted
      end

      def without(others)
        dup.delete_if { |item| others.include?(item) }
      end
    end
  end
end
