module Cassanity
  module ArgumentGenerators
    class ColumnFamilyCreate
      def call(args = {})
        name        = args.fetch(:name)
        columns     = args.fetch(:columns)
        primary_key = args.fetch(:primary_key)
        with        = args.fetch(:with) { {} }
        definitions, variables = [], []

        columns.each do |name, type|
          definitions << "#{name} #{type}"
        end

        definitions << "PRIMARY KEY (%s)" % Array(primary_key).join(', ')

        cql_definition = definitions.join(', ')

        cql = "CREATE COLUMNFAMILY #{name} (%s)" % cql_definition

        unless with.empty?
          cql << " WITH "
          withs = []
          with.each do |key, value|
            if value.is_a?(Hash)
              value.each do |sub_key, sub_value|
                withs << "#{key}:#{sub_key} = ?"
                variables << sub_value
              end
            else
              withs << "#{key} = ?"
              variables << value
            end
          end
          cql << withs.join(' AND ')
        end

        [cql, *variables]
      end
    end
  end
end
