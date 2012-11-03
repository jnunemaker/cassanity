module Cassanity
  module ArgumentGenerators
    class WhereClause
      def call(args = {})
        where = args.fetch(:where)
        cql, variables, wheres = '', [], []

        where.each do |key, value|
          if value.is_a?(Array)
            wheres << "#{key} IN (?)"
            variables << value
          else
            wheres << "#{key} = ?"
            variables << value
          end
        end

        cql << " WHERE #{wheres.join(' AND ')}"

        [cql, *variables]
      end
    end
  end
end
