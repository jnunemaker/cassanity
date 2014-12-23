
module Cassanity
  class PreparedStatement

    # Internal: Initializes a PreparedStatement from a Cql::Client::PreparedStatement.
    #
    # result - The Cql::Client::PreparedStatement received from the prepare request.
    def initialize(result)
      @driver_stmt = result
    end

    # Public: Executes the prepared statement for a given values.
    #
    # variables - The Hash of variables to use to execute.
    def execute(variables)
      @driver_stmt.execute *fields.map { |field| variables.fetch field }
    end

    private

    def fields
      @fields ||= extract_fields
    end

    def extract_fields
      @driver_stmt.metadata.collect { |field| field.column_name.to_sym }
    end
  end
end
