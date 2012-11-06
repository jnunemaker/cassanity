module Cassanity
  module ArgumentGenerators
    class IndexCreate
      def call(args = {})
        name = args[:name]
        column_name = args.fetch(:column_name)
        column_family_name = args.fetch(:column_family_name)

        if (keyspace_name = args[:keyspace_name])
          column_family_name = "#{keyspace_name}.#{column_family_name}"
        end

        cql = "CREATE INDEX"
        cql << " #{name}" unless name.nil?
        cql << " ON #{column_family_name} (#{column_name})"
        [cql]
      end
    end
  end
end
