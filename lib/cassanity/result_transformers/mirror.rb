module Cassanity
  module ResultTransformers
    class Mirror

      # Internal: Returns whatever result is passed to it. This is used as the
      # default result transformer when a command does not have one.
      def call(driver, result, args = nil)
        result
      end
    end
  end
end
