require 'cassanity/column_family'

module Cassanity
  module ResultTransformers
    class Keyspaces

      # Internal: Turns result into Array of keyspaces.
      def call(result, args = {})
        keyspaces = []
        result.each do |row|
          name = row['name'] || row['keyspace'] || row['keyspace_name']
          keyspaces << Keyspace.new({
            name: name,
            executor: args[:executor],
          })
        end
        keyspaces
      end
    end
  end
end
