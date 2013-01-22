module Cassanity
  module ArgumentGenerators
    class ColumnFamilyInsert

      # Internal
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
