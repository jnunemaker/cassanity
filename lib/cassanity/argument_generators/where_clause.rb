require 'cassanity/operator'

module Cassanity
  module ArgumentGenerators
    class WhereClause

      # Internal
      def call(args = {})
        where = args[:where]
        cql = ''
        return [cql] if where.nil? || where.empty?

        variables, wheres = [], []

        where.each do |key, value|
          case value
          when Array
            wheres << "#{key} IN (?)"
            variables << value
          when Range
            start, finish = value.begin, value.end
            end_operator = value.exclude_end? ? '<' : '<='
            wheres << "#{key} >= ?"
            wheres << "#{key} #{end_operator} ?"
            variables << start
            variables << finish
          when Cassanity::Operator
            wheres << "#{key} #{value.symbol} ?"
            variables << value.value
          else
            wheres << "#{key} = ?"
            variables << value
          end
        end

        cql << " WHERE #{wheres.join(' AND ')}"

        [cql, *variables]
      end
    end
  end
end
