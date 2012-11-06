module Cassanity
  module ArgumentGenerators
    class KeyspaceUse

      # Internal
      def call(args = {})
        name = args.fetch(:name)
        cql = "USE #{name}"
        [cql]
      end
    end
  end
end
