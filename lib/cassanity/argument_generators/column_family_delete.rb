require 'cassanity/argument_generators/where_clause'
require 'cassanity/argument_generators/using_clause'

module Cassanity
  module ArgumentGenerators
    class ColumnFamilyDelete

      # Internal
      def initialize(args = {})
        @using_clause = args.fetch(:using_clause) { UsingClause.new }
        @where_clause = args.fetch(:where_clause) { WhereClause.new }
      end

      # Internal
      def call(args = {})
        name    = args.fetch(:column_family_name)
        where   = args.fetch(:where)
        columns = args.fetch(:columns) { [] }
        using   = args[:using]

        if (keyspace_name = args[:keyspace_name])
          name = "#{keyspace_name}.#{name}"
        end

        column_clause, variables = '', []
        columns ||= []

        cols = []
        [columns].flatten.each do |c|
          if Hash === c
            Array(c.values.first).each { |key| cols << "#{c.keys.first}[#{key}]" }
          else
            cols << c
          end
        end
        column_clause = " #{cols.join(', ')}".rstrip

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
