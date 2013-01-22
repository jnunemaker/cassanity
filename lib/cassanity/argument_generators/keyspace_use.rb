module Cassanity
  module ArgumentGenerators
    class KeyspaceUse

      # Internal
      def call(args = {})
        name = args.fetch(:keyspace_name)
        cql = "USE #{name}"
        [cql]
      end
    end
  end
end
