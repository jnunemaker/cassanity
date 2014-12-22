
module Cassanity
  class PreparedStatement

    attr_reader :fields

    def initialize(result, fields)
      @fields = fields
      @driver_stmt = result
    end

    def execute(variables)
      @driver_stmt.execute *fields.map { |field| variables.fetch field }
    end

  end
end
