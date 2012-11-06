module Cassanity
  module ArgumentGenerators
    class ColumnFamilyDrop

      # Internal
      def call(args = {})
        name = args.fetch(:name)

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        cql = "DROP COLUMNFAMILY %s" % name
        [cql]
      end
    end
  end
end
