module Cassanity
  module ArgumentGenerators
    class KeyspaceDrop
      def call(args = {})
        name = args.fetch(:name)
        cql = "DROP KEYSPACE %s" % name
        [cql]
      end
    end
  end
end
