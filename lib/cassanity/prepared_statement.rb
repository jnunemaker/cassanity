
module Cassanity
  class PreparedStatement

    # Internal: Initializes a PreparedStatement from a Cassandra::Statements::Prepared.
    #
    # driver - The Cassandra::Cluster against which the prepared statement will be run
    # prepared_statement - The Cassandra::Statements::Prepared received from the prepare request.
    # result_transformer - The Cassanity::ResultTrasnsformer instance to apply on the result
    def initialize(driver, prepared_statement, result_transformer = ResultTransformers::Mirror.new, result_transformer_args = {})
      @session = driver.session
      @prepared_statement = prepared_statement
      @result_transformer = result_transformer
      @result_transformer_args = result_transformer_args
    end

    # Public: Executes the prepared statement for a given values.
    #
    # variables - The Hash of variables to use to execute.
    def execute(variables)
      @result_transformer.call @session.execute(@prepared_statement, arguments: args_from(variables)), @result_transformer_args
    end

    # Public: Asynchronously executes the prepared statement for the given values.
    #
    # variables - The Hash of variables to use to execute
    def execute_async(variables)
      ::Cassanity::Future.new @session.execute_async @prepared_statement, arguments: args_from(variables)
    end

    private

    def args_from(variables)
      fields.map { |field| variables.fetch field }
    end

    def fields
      @fields ||= extract_fields
    end

    def extract_fields
      # TODO: This instance variable get is VERY risky.
      # Change this into named attributes ASAP. In order to do this we need to
      # prepare the statement using named attributes rather than positional.
      @prepared_statement.instance_variable_get(:@params_metadata).collect { |param| param[2].to_sym }
    end
  end
end
