module Cassanity
  module ResultTransformers
    class ColumnFamilySelect
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
