require 'forwardable'
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
require 'cassanity/argument_generators/column_family_prepare_insert'
require 'cassanity/argument_generators/column_family_update'
require 'cassanity/argument_generators/column_family_delete'
require 'cassanity/argument_generators/column_family_alter'
require 'cassanity/argument_generators/index_create'
require 'cassanity/argument_generators/index_drop'
require 'cassanity/argument_generators/batch'
require 'cassanity/argument_generators/columns'
require 'cassanity/result_transformers/result_to_array'
require 'cassanity/result_transformers/keyspaces'
require 'cassanity/result_transformers/column_families'
require 'cassanity/result_transformers/columns'
require 'cassanity/result_transformers/mirror'
require 'cassanity/result_transformers/prepared_statement'
require 'cassanity/retry_strategies/retry_n_times'
require 'cassanity/retry_strategies/exponential_backoff'
require 'cassanity/command_runners/execute_command_runner'
require 'cassanity/command_runners/prepare_command_runner'

module Cassanity
  module Executors
    class CqlRb
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
        column_family_prepare_insert: ArgumentGenerators::ColumnFamilyPrepareInsert.new,
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
        keyspaces: ResultTransformers::Keyspaces.new,
        column_families: ResultTransformers::ColumnFamilies.new,
        column_family_select: ResultTransformers::ResultToArray.new,
        columns: ResultTransformers::Columns.new,
        column_family_prepare_insert: ResultTransformers::PreparedStatement.new
      }

      # Private: Default retry strategy to retry N times.
      DefaultRetryStrategy = RetryStrategies::RetryNTimes.new

      # Private: Default result transformer for commands that do not have one.
      Mirror = ResultTransformers::Mirror.new

      # Private: Hash of command runners for commands.
      DefaultCommandRunners = {
        column_family_prepare_insert: CommandRunners::PrepareCommandRunner.new
      }

      # Private: Default command runner.
      DefaultCommandRunner = CommandRunners::ExecuteCommandRunner.new

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

      # Private: What strategy to use when retrying Cassandra commands
      attr_reader :retry_strategy

      # Internal: Initializes a cassandra-cql based CQL executor.
      #
      # args - The Hash of arguments.
      #        :driver - The Cql::Client connection instance.
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
      #        :retry_strategy      - What retry strategy to use on failed
      #                               Cql::Client calls
      #                               (default: Cassanity::Instrumenters::RetryNTimes)
      #        :command_runners     - A Hash where each key is a command name
      #                               and each value is the related command
      #                               runner that responds to `run` (optional).
      #
      # Examples
      #
      #   driver = Cql::Client.connect(hosts: ['cassandra.example.com'])
      #   Cassanity::Executors::CqlRb.new(driver: driver)
      #
      def initialize(args = {})
        @driver = args.fetch(:driver)
        @instrumenter = args[:instrumenter] || Instrumenters::Noop
        @argument_generators = args.fetch(:argument_generators, DefaultArgumentGenerators)
        @result_transformers = args.fetch(:result_transformers, DefaultResultTransformers)
        @retry_strategy = args[:retry_strategy] || DefaultRetryStrategy
        @command_runners = args.fetch(:command_runners, DefaultCommandRunners)
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
            runner = @command_runners.fetch(command, DefaultCommandRunner)
          rescue KeyError => e
            raise Cassanity::UnknownCommand
          end

          arguments = args[:arguments]

          send_use_command = false
          if arguments
            # TODO: As a temporary measure, we remove this deprecated option
            # while we have time to update each gem (e.g., adapter-cassanity)
            # that sets it. Consistency should be specified at the connection
            # level for now.
            if arguments[:using]
              arguments[:using].delete(:consistency)
            end

            # Instrumentation parameters
            if (keyspace_name = arguments[:keyspace_name])
              payload[:keyspace_name] = keyspace_name
            end
            if (column_family_name = arguments[:column_family_name])
              payload[:column_family_name] = column_family_name
            end

            # Select the correct keyspace before executing the CQL query
            if command != :keyspace_create && (keyspace_name = arguments[:keyspace_name])
              send_use_command = true
            end
          end

          begin
            cql, *variables = generator.call(arguments)
            payload[:cql] = cql
            payload[:cql_variables] = variables

            result = @retry_strategy.execute(payload) do
              runner.use(@driver, keyspace_name) if send_use_command
              runner.run(@driver, cql, variables)
            end

            transformer = @result_transformers.fetch(command, Mirror)
            transformed_result = transformer.call(@driver, result, args[:transformer_arguments])
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
