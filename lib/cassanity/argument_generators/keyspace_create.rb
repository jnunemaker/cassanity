require 'cassanity/argument_generators/with_clause'

module Cassanity
  module ArgumentGenerators
    class KeyspaceCreate

      def initialize(args = {})
        @with_clause = args.fetch(:with_clause) { WithClause.new }
      end

      # Internal
      def call(args = {})
        options, variables = [], []
        name = args.fetch(:keyspace_name)
        cql = "CREATE KEYSPACE #{name}"

        replication = default_replication_options.merge(args[:replication] || {})

        with_cql, *with_variables = @with_clause.call(with: { replication: replication })
        cql << with_cql
        variables.concat(with_variables)

        [cql, *variables]
      end

      # Private
      def default_replication_options
        {
          class: 'SimpleStrategy',
          replication_factor: 1,
        }
      end
    end
  end
end
