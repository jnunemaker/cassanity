module Cassanity
  module ResultTransformers
    class ColumnFamilySelect

      # Internal: Turns result into Array of Hashes.
      def call(result)
        rows = []
        result.fetch_hash do |row|
          rows << row
        end
        rows
      end
    end
  end
end
