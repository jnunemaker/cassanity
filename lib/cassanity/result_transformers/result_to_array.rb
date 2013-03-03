module Cassanity
  module ResultTransformers
    class ResultToArray

      # Internal: Turns result into Array of Hashes.
      def call(result, args = nil)
        rows = []
        result.fetch_hash do |row|
          rows << row
        end
        rows
      end
    end
  end
end
