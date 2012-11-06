module Cassanity
  module ResultTransformers
    class Mirror
      # Public: Returns whatever result is passed to it. This is used as the
      # default result transformer when a command does not have one.
      def call(result)
        result
      end
    end
  end
end
