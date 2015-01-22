require 'cassanity/operators/eq'

module Cassanity
  module ArgumentGenerators
    class IfClause

      # Internal
      def call(args = {})
        ifc = args[:if]
        cql = ''
        return [cql] if ifc.nil? || ifc.empty?

        variables, conditions = [], []

        ifc.each do |key, value|
          case value
          when Cassanity::Operators::Eq
            conditions << "#{key} #{value.symbol} ?"
            variables << value.value
          else
            conditions << "\"#{key}\" = ?"
            variables << value
          end
        end

        cql << " IF #{conditions.join(' AND ')}"

        [cql, *variables]
      end
    end
  end
end
