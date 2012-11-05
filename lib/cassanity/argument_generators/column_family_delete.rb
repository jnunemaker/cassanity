require 'cassanity/argument_generators/where_clause'
require 'cassanity/argument_generators/using_clause'

module Cassanity
  module ArgumentGenerators
    class ColumnFamilyDelete

      def initialize(args = {})
        @using_clause = args.fetch(:using_clause) { UsingClause.new }
        @where_clause = args.fetch(:where_clause) { WhereClause.new }
      end

      # Public: Converts a Hash of arguments to CQL with bound variables.
      #
      # args - The Hash of arguments to use.
      #        :name - The String name of the column family
      #        :where - The Hash of options to use to filter the delete
      #        :columns - The Array of columns you would like to delete
      #                   (default is all columns) (optional).
      #        :using - The Hash of options for the query ie: consistency, ttl,
      #                 and timestamp (default: {}) (optional).
      #
      # Examples
      #
      #   call({
      #     name: 'apps',
      #     where: {
      #       id: '1',
      #     },
      #   })
      #
      # Returns Array where first element is CQL string and the rest are
      #   bound values.
      def call(args = {})
        name    = args.fetch(:name)
        where   = args.fetch(:where)
        columns = args.fetch(:columns) { [] }
        using   = args[:using]

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        column_clause, variables = '', []

        unless columns.empty?
          column_clause = " #{columns.join(', ')}"
        end

        cql = "DELETE#{column_clause} FROM #{name}"

        using_cql, *using_variables = @using_clause.call(using: using)
        cql << using_cql
        variables.concat(using_variables)

        where_cql, *where_variables = @where_clause.call(where: where)
        cql << where_cql
        variables.concat(where_variables)

        [cql, *variables]
      end
    end
  end
end
