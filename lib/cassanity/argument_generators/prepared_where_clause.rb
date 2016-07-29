require 'cassanity/operator'
require 'cassanity/operators/eq'
require 'cassanity/operators/gt'
require 'cassanity/operators/gte'
require 'cassanity/operators/lt'
require 'cassanity/operators/lte'
require 'cassanity/range'

module Cassanity

  class RangePlaceholder

    attr_reader :comparator

    def initialize(exclusive = true)
      @comparator = exclusive ? '<' : '<='
    end
  end

  class SingleFieldPlaceholder

    attr_reader :symbol

    def initialize(symbol = '=')
      @symbol = symbol
    end
  end

  class ArrayPlaceholder

    attr_reader :length

    def initialize(length)
      @length = length
    end
  end

  module ArgumentGenerators
    class PreparedWhereClause

      # Internal
      def call(args = {})
        where = args[:where]
        cql = ''
        return [cql] if where.nil? || where.empty?

        wheres = []

        where.each do |key, value|
          case value
          when ArrayPlaceholder
            binds = (['?'] * value.length).join ','
            wheres << "#{key} IN (#{binds})"
          when RangePlaceholder
            wheres << "#{key} >= ?"
            wheres << "#{key} #{value.comparator} ?"
          when SingleFieldPlaceholder
            wheres << "\"#{key}\" #{value.symbol} ?"
          end
        end

        cql << " WHERE #{wheres.join(' AND ')}"

        [cql, []]
      end
    end
  end
end
