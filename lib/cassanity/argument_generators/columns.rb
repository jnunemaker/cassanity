require 'cassanity/argument_generators/where_clause'

module Cassanity
  module ArgumentGenerators
    class Columns

      def initialize(args = {})
        @where_clause = args.fetch(:where_clause) { WhereClause.new }
      end

      # Internal
      def call(args = {})
        where = {}
        variables = []
        cql = 'SELECT * FROM system.schema_columns'

        if (keyspace_name = args[:keyspace_name])
          where[:keyspace] = keyspace_name
        end

        if (column_family_name = args[:column_family_name])
          where[:columnfamily] = column_family_name
        end

        where_cql, *where_variables = @where_clause.call(where: where)
        cql << where_cql
        variables.concat(where_variables)

        [cql, *variables]
      end
    end
  end
end
