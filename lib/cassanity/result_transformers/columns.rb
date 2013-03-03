require 'cassanity/column'

module Cassanity
  module ResultTransformers
    class Columns

      # Internal: Turns result into Array of column families.
      def call(result, args = {})
        columns = []
        result.fetch_hash do |row|
          columns << Column.new({
            name: row['column'],
            type: row['validator'],
            column_family: args[:column_family],
          })
        end
        columns
      end
    end
  end
end
