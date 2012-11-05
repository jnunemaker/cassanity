require 'cassanity/argument_generators/where_clause'
require 'cassanity/argument_generators/set_clause'
require 'cassanity/argument_generators/using_clause'

module Cassanity
  module ArgumentGenerators
    class ColumnFamilyUpdate

      def initialize(args = {})
        @using_clause = args.fetch(:using_clause) { UsingClause.new }
        @set_clause   = args.fetch(:set_clause)   { SetClause.new }
        @where_clause = args.fetch(:where_clause) { WhereClause.new }
      end

      # Public: Converts a Hash of arguments to CQL with bound variables.
      #
      # args - The Hash of arguments to use.
      #        :name - The String name of the column family
      #        :set - The Hash of data to actually update
      #        :where - The Hash of options to use to filter the update
      #        :using - The Hash of options for the query ie: consistency, ttl,
      #                 and timestamp (optional).
      #
      # Examples
      #
      #   call({
      #     name: 'apps',
      #     set: {
      #       name: 'GitHub',
      #     },
      #     where: {
      #       :id => '1',
      #     }
      #   })
      #
      # Returns Array where first element is CQL string and the rest are
      #   bound values.
      def call(args = {})
        name  = args.fetch(:name)
        set   = args.fetch(:set)
        where = args.fetch(:where)
        using = args[:using] || {}

        variables = []

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        cql = "UPDATE #{name}"

        using_cql, *using_variables = @using_clause.call(using: using)
        cql << using_cql
        variables.concat(using_variables)

        set_cql, *set_variables = @set_clause.call(set: set)
        cql << set_cql
        variables.concat(set_variables)

        where_cql, *where_variables = @where_clause.call(where: where)
        cql << where_cql
        variables.concat(where_variables)

        [cql, *variables]
      end
    end
  end
end
