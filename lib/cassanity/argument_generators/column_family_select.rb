require 'cassanity/argument_generators/using_clause'
require 'cassanity/argument_generators/where_clause'
require 'cassanity/argument_generators/order_clause'
require 'cassanity/argument_generators/limit_clause'

module Cassanity
  module ArgumentGenerators
    class ColumnFamilySelect

      # Internal
      def initialize(args = {})
        @using_clause = args.fetch(:using_clause) { UsingClause.new }
        @where_clause = args.fetch(:where_clause) { WhereClause.new }
        @order_clause = args.fetch(:order_clause) { OrderClause.new }
        @limit_clause = args.fetch(:limit_clause) { LimitClause.new }
      end

      # Internal
      def call(args = {})
        select = Array(args.fetch(:select, '*'))
        name   = args.fetch(:name)
        where  = args[:where]
        using  = args[:using]
        order  = args[:order]
        limit  = args[:limit]

        variables = []

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        cql = "SELECT #{select.join(', ')} FROM #{name}"

        using_cql, *using_variables = @using_clause.call(using: using)
        cql << using_cql
        variables.concat(using_variables)

        where_cql, *where_variables = @where_clause.call(where: where)
        cql << where_cql
        variables.concat(where_variables)

        order_cql, *order_variables = @order_clause.call(order: order)
        cql << order_cql
        variables.concat(order_variables)

        limit_cql, *limit_variables = @limit_clause.call(limit: limit)
        cql << limit_cql
        variables.concat(limit_variables)

        [cql, *variables]
      end
    end
  end
end
