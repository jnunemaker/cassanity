module Cassanity
  module ArgumentGenerators
    class IndexDrop
      def call(args = {})
        name = args.fetch(:name)
        cql = "DROP INDEX #{name}"
        [cql]
      end
    end
  end
end
