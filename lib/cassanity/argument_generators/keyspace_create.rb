module Cassanity
  module ArgumentGenerators
    class KeyspaceCreate

      # Internal
      def call(args = {})
        options, variables = [], []
        name = args.fetch(:name)
        cql = "CREATE KEYSPACE #{name} WITH "

        with = {
          strategy_class: default_strategy_class,
          strategy_options: default_strategy_options,
        }

        if args[:strategy_class]
          with[:strategy_class] = args[:strategy_class]
        end

        cql << "strategy_class = ? AND "
        variables << with[:strategy_class]

        if args[:strategy_options]
          args[:strategy_options].each do |key, value|
            with[:strategy_options][key] = value
          end
        end

        with[:strategy_options].each do |key, value|
          options << "strategy_options:#{key} = ?"
          variables << value
        end
        cql << options.join(' AND ')

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
