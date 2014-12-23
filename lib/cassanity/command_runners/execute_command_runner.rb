
require 'cassanity/statement'

module Cassanity
  module CommandRunners
    class ExecuteCommandRunner

      def initialize(driver)
        @driver = driver
      end

      def use(keyspace)
        @driver.use(keyspace)
      end

      def run(cql, variables)
        statement = Cassanity::Statement.new(cql)
        @driver.execute(statement.interpolate(variables))
      end

    end
  end
end
