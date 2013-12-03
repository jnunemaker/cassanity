module Cassanity
  module ResultTransformers
    class ResultToArray

      # Internal: Turns result into Array of Hashes.
      def call(result, args = nil)
        result.map { |row| row }
      end
    end
  end
end
