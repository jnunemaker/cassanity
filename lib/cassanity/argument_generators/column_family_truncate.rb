module Cassanity
  module ArgumentGenerators
    class ColumnFamilyTruncate
      def call(args = {})
        name = args.fetch(:name)
        cql = "TRUNCATE #{name}"
        [cql]
      end
    end
  end
end
