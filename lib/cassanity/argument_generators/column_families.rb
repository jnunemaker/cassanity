module Cassanity
  module ArgumentGenerators
    class ColumnFamilies

      # Internal
      def call(args = {})
        variables = []
        cql = 'SELECT * FROM system.schema_columnfamilies'

        if (keyspace_name = args[:keyspace_name])
          cql << ' WHERE "keyspace_name" = ?'
          variables << keyspace_name
        end

        [cql, *variables]
      end
    end
  end
end
