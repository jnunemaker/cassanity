module Cassanity
  module ArgumentGenerators
    class KeyspaceDrop

      # Internal
      def call(args = {})
        name = args.fetch(:keyspace_name)
        cql = "DROP KEYSPACE #{name}"
        [cql]
      end
    end
  end
end
