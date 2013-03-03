require 'forwardable'
require 'cassandra-cql'
require 'cassanity/error'
require 'cassanity/instrumenters/noop'
require 'cassanity/argument_generators/keyspaces'
require 'cassanity/argument_generators/keyspace_create'
require 'cassanity/argument_generators/keyspace_drop'
require 'cassanity/argument_generators/keyspace_use'
require 'cassanity/argument_generators/column_families'
require 'cassanity/argument_generators/column_family_create'
require 'cassanity/argument_generators/column_family_drop'
require 'cassanity/argument_generators/column_family_truncate'
require 'cassanity/argument_generators/column_family_select'
require 'cassanity/argument_generators/column_family_insert'
require 'cassanity/argument_generators/column_family_update'
require 'cassanity/argument_generators/column_family_delete'
require 'cassanity/argument_generators/column_family_alter'
require 'cassanity/argument_generators/index_create'
require 'cassanity/argument_generators/index_drop'
require 'cassanity/argument_generators/batch'
require 'cassanity/argument_generators/columns'
require 'cassanity/result_transformers/result_to_array'
require 'cassanity/result_transformers/column_families'
require 'cassanity/result_transformers/columns'
require 'cassanity/result_transformers/mirror'

module Cassanity
  module Executors
    class CassandraCql
      extend Forwardable

      # Private: Hash of commands to related argument generators.
      DefaultArgumentGenerators = {
        keyspaces: ArgumentGenerators::Keyspaces.new,
        keyspace_create: ArgumentGenerators::KeyspaceCreate.new,
        keyspace_drop: ArgumentGenerators::KeyspaceDrop.new,
        keyspace_use: ArgumentGenerators::KeyspaceUse.new,
        column_families: ArgumentGenerators::ColumnFamilies.new,
        column_family_create: ArgumentGenerators::ColumnFamilyCreate.new,
        column_family_drop: ArgumentGenerators::ColumnFamilyDrop.new,
        column_family_truncate: ArgumentGenerators::ColumnFamilyTruncate.new,
        column_family_select: ArgumentGenerators::ColumnFamilySelect.new,
        column_family_insert: ArgumentGenerators::ColumnFamilyInsert.new,
        column_family_update: ArgumentGenerators::ColumnFamilyUpdate.new,
        column_family_delete: ArgumentGenerators::ColumnFamilyDelete.new,
        column_family_alter: ArgumentGenerators::ColumnFamilyAlter.new,
        index_create: ArgumentGenerators::IndexCreate.new,
        index_drop: ArgumentGenerators::IndexDrop.new,
        batch: ArgumentGenerators::Batch.new,
        columns: ArgumentGenerators::Columns.new,
      }

      # Private: Hash of commands to related result transformers.
      DefaultResultTransformers = {
        keyspaces: ResultTransformers::ResultToArray.new,
        column_families: ResultTransformers::ColumnFamilies.new,
        column_family_select: ResultTransformers::ResultToArray.new,
        columns: ResultTransformers::Columns.new,
      }

      # Private: Default result transformer for commands that do not have one.
      Mirror = ResultTransformers::Mirror.new

      # Private: Forward #instrument to instrumenter.
      def_delegator :@instrumenter, :instrument

      # Private
      attr_reader :driver

      # Private
      attr_reader :argument_generators

      # Private
      attr_reader :result_transformers

      # Private: What should be used to instrument all the things.
      attr_reader :instrumenter

      # Internal: Initializes a cassandra-cql based CQL executor.
      #
      # args - The Hash of arguments.
      #        :driver - The CassandraCQL::Database connection instance.
      #        :instrumenter - What should be used to instrument all the things
      #                        (default: Cassanity::Instrumenters::Noop).
      #        :argument_generators - A Hash where each key is a command name
      #                               and each value is the related argument
      #                               generator that responds to `call`
      #                               (optional).
      #        :result_transformers - A Hash where each key is a command name
      #                               and each value is the related result
      #                               transformer that responds to `call`
      #                               (optional).
      #
      # Examples
      #
      #   driver = CassandraCQL::Database.new('host', cql_version: '3.0.0')
      #   Cassanity::Executors::CassandraCql.new(driver: driver)
      #
      def initialize(args = {})
        @driver = args.fetch(:driver)
        @instrumenter = args[:instrumenter] || Instrumenters::Noop
        @argument_generators = args.fetch(:argument_generators, DefaultArgumentGenerators)
        @result_transformers = args.fetch(:result_transformers, DefaultResultTransformers)
      end

      # Internal: Execute a CQL query.
      #
      # args - One or more arguments to send to execute. First should always be
      #        String CQL query. The rest should be the bound variables if any
      #        are needed.
      #
      # Examples
      #
      #   call({
      #     command: :keyspaces,
      #   })
      #
      #   call({
      #     command: :keyspace_create,
      #     arguments: {keyspace_name: 'analytics'},
      #   })
      #
      # Returns the result of execution.
      # Raises Cassanity::Error if anything goes wrong during execution.
      def call(args = {})
        instrument('cql.cassanity') do |payload|
          begin
            command = args.fetch(:command)
            payload[:command] = command
            generator = @argument_generators.fetch(command)
          rescue KeyError => e
            raise Cassanity::UnknownCommand
          end

          arguments = args[:arguments]

          if arguments
            if (keyspace_name = arguments[:keyspace_name])
              payload[:keyspace_name] = keyspace_name
            end

            if (column_family_name = arguments[:column_family_name])
              payload[:column_family_name] = column_family_name
            end
          end

          begin
            execute_arguments = generator.call(arguments)
            payload[:cql] = execute_arguments[0]
            payload[:cql_variables] = execute_arguments[1..-1]
            result = @driver.execute(*execute_arguments)
            transformer = @result_transformers.fetch(command, Mirror)
            transformed_result = transformer.call(result, args[:transformer_arguments])
            payload[:result] = transformed_result
          rescue StandardError => e
            raise Cassanity::Error
          end

          transformed_result
        end
      end

      # Public
      def inspect
        attributes = [
          "driver=#{@driver.inspect}",
        ]
        "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
      end
    end
  end
end
