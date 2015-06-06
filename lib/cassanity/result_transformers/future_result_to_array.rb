module Cassanity
  module ResultTransformers
    class FutureResultToArray

      # Internal: Turns result into Array of Hashes.
      def call(future, args = nil)
        future.result_transformer = ResultToArray.new
        future
      end
    end
  end
end
