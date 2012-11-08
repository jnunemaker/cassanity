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
        name = args.fetch(:name)
        cql = "CREATE KEYSPACE #{name}"

        with = {
          strategy_class: default_strategy_class,
          strategy_options: default_strategy_options,
        }

        if args[:strategy_class]
          with[:strategy_class] = args[:strategy_class]
        end

        if args[:strategy_options]
          args[:strategy_options].each do |key, value|
            with[:strategy_options][key] = value
          end
        end

        with_cql, *with_variables = @with_clause.call(with: with)
        cql << with_cql
        variables.concat(with_variables)

        [cql, *variables]
      end

      # Private
      def default_strategy_class
        'SimpleStrategy'
      end

      # Private
      def default_strategy_options
        {
          replication_factor: 1,
        }
      end
    end
  end
end
