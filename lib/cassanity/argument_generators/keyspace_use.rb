module Cassanity
  module ArgumentGenerators
    class KeyspaceUse
      def call(args = {})
        name = args.fetch(:name)
        cql = "USE #{name}"
        [cql]
      end
    end
  end
end
