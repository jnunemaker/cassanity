module Cassanity
  module ArgumentGenerators
    class ColumnFamilyTruncate

      # Internal
      def call(args = {})
        name = args.fetch(:name)

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        cql = "TRUNCATE #{name}"
        [cql]
      end
    end
  end
end
