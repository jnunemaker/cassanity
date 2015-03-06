require 'cassanity/column_family'

module Cassanity
  module ResultTransformers
    class ColumnFamilies

      # Internal: Turns result into Array of column families.
      def call(driver, result, args = {})
        column_families = []
        result.each do |row|
          column_families << ColumnFamily.new({
            name: row['columnfamily'] || row['columnfamily_name'],
            keyspace: args[:keyspace],
          })
        end
        column_families
      end
    end
  end
end
