require 'cassanity/argument_generators/if_clause'
require 'cassanity/argument_generators/where_clause'
require 'cassanity/argument_generators/set_clause'
require 'cassanity/argument_generators/using_clause'

module Cassanity
  module ArgumentGenerators
    class ColumnFamilyUpdate

      # Internal
      def initialize(args = {})
        @using_clause = args.fetch(:using_clause) { UsingClause.new }
        @set_clause   = args.fetch(:set_clause)   { SetClause.new }
        @where_clause = args.fetch(:where_clause) { WhereClause.new }
        @if_clause    = args.fetch(:if_clause)    { IfClause.new }
      end

      # Internal
      def call(args = {})
        name  = args.fetch(:column_family_name)
        set   = args.fetch(:set)
        where = args.fetch(:where)
        ifc   = args[:if] || {}
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

        if_cql, *if_variables = @if_clause.call(if: ifc)
        cql << if_cql
        variables.concat(if_variables)

        [cql, *variables]
      end
    end
  end
end
