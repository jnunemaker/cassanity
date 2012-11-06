require 'cassanity/argument_generators/with_clause'

module Cassanity
  module ArgumentGenerators
    class ColumnFamilyCreate

      # Internal
      def initialize(args = {})
        @with_clause = args.fetch(:with_clause) { WithClause.new }
      end

      # Internal
      def call(args = {})
        name        = args.fetch(:name)
        schema      = args.fetch(:schema)
        columns     = schema.columns
        primary_key = schema.primary_key
        with        = schema.with

        definitions, variables = [], []

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        columns.each do |name, type|
          definitions << "#{name} #{type}"
        end

        definitions << "PRIMARY KEY (%s)" % Array(primary_key).join(', ')

        cql_definition = definitions.join(', ')

        cql = "CREATE COLUMNFAMILY #{name} (%s)" % cql_definition

        with_cql, *with_variables = @with_clause.call(with: with)
        cql << with_cql
        variables.concat(with_variables)

        [cql, *variables]
      end
    end
  end
end
