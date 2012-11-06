require 'cassanity/argument_generators/with_clause'

module Cassanity
  module ArgumentGenerators
    class ColumnFamilyAlter
      def initialize(args = {})
        @with_clause = args.fetch(:with_clause) { WithClause.new }
      end

      def call(args = {})
        name = args.fetch(:name)
        with = args[:with] || {}

        variables = []

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        cql = "ALTER COLUMNFAMILY #{name}"

        if (alter = args[:alter])
          column_name, column_type = alter.keys.first, alter.values.first
          cql << " ALTER #{column_name} TYPE #{column_type}"
        end

        if (add = args[:add])
          column_name, column_type = add.keys.first, add.values.first
          cql << " ADD #{column_name} #{column_type}"
        end

        if (column_name = args[:drop])
          cql << " DROP #{column_name}"
        end

        with_cql, *with_variables = @with_clause.call(with: with)
        cql << with_cql
        variables.concat(with_variables)

        [cql, *variables]
      end
    end
  end
end
