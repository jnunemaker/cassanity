module Cassanity
  module ArgumentGenerators
    class Keyspaces
      def call(args = {})
        cql = "SELECT * FROM system.schema_keyspaces"
        [cql]
      end
    end
  end
end
