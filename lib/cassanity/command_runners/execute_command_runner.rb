require 'cassanity/statement'

module Cassanity
  module CommandRunners
    class ExecuteCommandRunner
      def use(driver, keyspace)
        driver.use(keyspace)
      end

      def run(driver, cql, variables)
        statement = Cassanity::Statement.new(cql)
        driver.execute(statement.interpolate(variables))
      end
    end
  end
end
