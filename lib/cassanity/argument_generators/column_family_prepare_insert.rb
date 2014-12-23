module Cassanity
  module ArgumentGenerators
    class ColumnFamilyPrepareInsert

      attr_reader :fields

      # Internal
      def call(args = {})
        name    = args.fetch(:column_family_name)
        @fields  = args.fetch(:fields)
        using   = args[:using] || {}
        binders = ['?'] * @fields.size

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        cql = "INSERT INTO #{name} (#{@fields.join(', ')}) VALUES (#{binders.join(', ')})"

        unless using.empty?
          statements = []
          using.each do |key, value|
            statements << "#{key.upcase} #{value}"
          end
          cql << " USING #{statements.join(' AND ')}"
        end

        [cql, []]
      end
    end
  end
end
