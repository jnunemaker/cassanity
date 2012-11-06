require 'cassanity/argument_generators/using_clause'

module Cassanity
  module ArgumentGenerators
    class Batch

      # Internal: Map of command to argument generator
      Commands = {
        insert: ColumnFamilyInsert.new,
        update: ColumnFamilyUpdate.new,
        delete: ColumnFamilyDelete.new,
      }

      def initialize(args = {})
        @using_clause = args.fetch(:using_clause) { UsingClause.new }
        @commands = args.fetch(:commands) { Commands }
      end

      def call(args = {})
        using = args[:using]
        modifications_argument = args.fetch(:modifications) { [] }

        variables = []
        cql = "BEGIN BATCH"

        using_cql, *using_variables = @using_clause.call(using: using)
        cql << using_cql
        variables.concat(using_variables)

        modifications = []
        modifications_argument.each do |modification|
          command_name, command_arguments = modification
          command = @commands.fetch(command_name)

          modification_cql, *modification_variables = command.call(command_arguments)
          modifications << modification_cql
          variables.concat(modification_variables)
        end

        unless modifications.empty?
          cql << " #{modifications.join(' ')}"
        end

        cql << " APPLY BATCH"

        [cql, *variables]
      end
    end
  end
end
