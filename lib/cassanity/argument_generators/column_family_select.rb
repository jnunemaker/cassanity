require 'cassanity/argument_generators/where_clause'

module Cassanity
  module ArgumentGenerators
    class ColumnFamilySelect

      # Internal
      def initialize(args = {})
        @where_clause = args.fetch(:where_clause) { WhereClause.new }
      end

      # Internal
      def call(args = {})
        select = Array(args.fetch(:select, '*'))
        name   = args.fetch(:name)
        where  = args[:where]

        variables = []

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        cql = "SELECT #{select.join(', ')} FROM #{name}"

        where_cql, *where_variables = @where_clause.call(where: where)
        cql << where_cql
        variables.concat(where_variables)

        [cql, *variables]
      end
    end
  end
end
