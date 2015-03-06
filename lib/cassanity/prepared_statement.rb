
module Cassanity
  class PreparedStatement

    # Internal: Initializes a PreparedStatement from a Cassandra::Statements::Prepared.
    #
    # driver - The Cassandra::Cluster against which the prepared statement will be run
    # prepared_statement - The Cassandra::Statements::Prepared received from the prepare request.
    def initialize(driver, prepared_statement)
      @session = driver.session
      @prepared_statement = prepared_statement
    end

    # Public: Executes the prepared statement for a given values.
    #
    # variables - The Hash of variables to use to execute.
    def execute(variables)
      @session.execute @prepared_statement, arguments: fields.map { |field| variables.fetch field }
    end

    private

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
