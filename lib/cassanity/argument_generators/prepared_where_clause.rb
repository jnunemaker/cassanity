require 'cassanity/operator'
require 'cassanity/operators/eq'
require 'cassanity/operators/gt'
require 'cassanity/operators/gte'
require 'cassanity/operators/lt'
require 'cassanity/operators/lte'
require 'cassanity/range'

module Cassanity

  class Placeholder

    def self.===(other)
      self == other || super(other)
    end

  end
  class RangePlaceholder < Placeholder ; end
  class VarcharPlaceholder < Placeholder ; end
  class ArrayPlaceholder < Placeholder

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
            wheres << "#{key} < ?"
          else
            wheres << "\"#{key}\" = ?"
          end
        end

        cql << " WHERE #{wheres.join(' AND ')}"

        [cql, []]
      end
    end
  end
end
