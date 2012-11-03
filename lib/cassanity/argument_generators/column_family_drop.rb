module Cassanity
  module ArgumentGenerators
    class ColumnFamilyDrop
      def call(args = {})
        name = args.fetch(:name)
        cql = "DROP COLUMNFAMILY %s" % name
        [cql]
      end
    end
  end
end
