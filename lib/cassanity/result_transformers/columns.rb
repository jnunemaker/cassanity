require 'cassanity/column'

module Cassanity
  module ResultTransformers
    class Columns

      # Internal: Turns result into Array of column families.
      def call(result, args = {})
        columns = []
        result.each do |row|
          columns << Column.new({
            name: row['column_name'],
            type: row['validator'],
            column_family: args[:column_family],
          })
        end
        columns
      end
    end
  end
end
