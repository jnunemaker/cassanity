require 'cassanity/argument_generators/using_clause'

module Cassanity
  module ArgumentGenerators
    class Batch

      # Private: List of supported batch types
      BatchTypes = ['COUNTER','LOGGED','UNLOGGED']

      # Private: Map of command to argument generator
      Commands = {
        insert: ColumnFamilyInsert.new,
        update: ColumnFamilyUpdate.new,
        delete: ColumnFamilyDelete.new,
      }

      # Internal
      def initialize(args = {})
        @using_clause = args.fetch(:using_clause) { UsingClause.new }
        @commands = args.fetch(:commands) { Commands }
      end

      # Internal
      def call(args = {})
        type = args[:type].to_s.upcase
        type = 'LOGGED' if type.empty?
        raise ArgumentError.new("invalid batch type") unless BatchTypes.include?(type)

        using = args[:using]
        modifications_argument = args.fetch(:modifications) { [] }

        variables = []
        cql = type == 'LOGGED' ? "BEGIN BATCH" : "BEGIN #{type} BATCH"

        using_cql, *using_variables = @using_clause.call(using: using)
        cql << using_cql
        variables.concat(using_variables)

        modifications = []
        modifications_argument.each do |modification|
          command_name, command_arguments = modification
          command = @commands.fetch(command_name)

          if args[:column_family_name]
            command_arguments[:column_family_name] ||= args[:column_family_name]
          end

          if args[:keyspace_name]
            command_arguments[:keyspace_name] ||= args[:keyspace_name]
          end

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
