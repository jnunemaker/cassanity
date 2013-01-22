module Cassanity
  module ArgumentGenerators
    class ColumnFamilyInsert

      # Internal: Converts a Hash of arguments to CQL with bound variables.
      #
      # args - The Hash of arguments to use.
      #        :column_family_name - The String name of the column family
      #        :data - The Hash of keys and values to insert
      #        :using - The Hash of options for the query ie: consistency, ttl,
      #                 and timestamp (optional).
      #
      # Examples
      #
      #   call({
      #     column_family_name: 'apps',
      #     data: {id: '1', name: 'GitHub'},
      #   })
      #
      #   call({
      #     column_family_name: 'apps',
      #     data: {id: '1', name: 'GitHub'},
      #     using: {consistency: 'quorum'},
      #   })
      #
      # Returns Array where first element is CQL string and the rest are
      #   bound values.
      def call(args = {})
        name    = args.fetch(:column_family_name)
        data    = args.fetch(:data)
        using   = args[:using] || {}
        keys    = data.keys
        binders = ['?'] * keys.size

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        cql = "INSERT INTO #{name} (#{keys.join(', ')}) VALUES (#{binders.join(', ')})"

        unless using.empty?
          statements = []
          using.each do |key, value|
            statements << "#{key.upcase} #{value}"
          end
          cql << " USING #{statements.join(' AND ')}"
        end

        [cql, *data.values]
      end
    end
  end
end
