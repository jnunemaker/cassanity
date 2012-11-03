module Cassanity
  module ArgumentGenerators
    class ColumnFamilyInsert
      # Public: Converts a Hash of arguments to CQL with bound variables.
      #
      # args - The Hash of arguments to use.
      #        :name - The String name of the column family
      #        :data - The Hash of keys and values to insert
      #        :using - The Hash of options for the query ie: consistency, ttl,
      #                 and timestamp (optional).
      #
      # Examples
      #
      #   call({
      #     name: 'apps',
      #     data: {id: '1', name: 'GitHub'},
      #   })
      #
      #   call({
      #     name: 'apps',
      #     data: {id: '1', name: 'GitHub'},
      #     using: {consistency: 'quorum'},
      #   })
      #
      # Returns Array where first element is CQL string and the rest are
      #   bound values.
      def call(args = {})
        name    = args.fetch(:name)
        data    = args.fetch(:data)
        using   = args[:using] || {}
        keys    = data.keys
        binders = ['?'] * keys.size
        cql     = "INSERT INTO #{name} (#{keys.join(', ')}) VALUES (#{binders.join(', ')})"

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
