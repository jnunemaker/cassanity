require 'cassanity/futures/future'

module Cassanity
  module CommandRunners
    class ExecuteAsyncCommandRunner < ExecuteCommandRunner
      def run(driver, cql, variables)
        statement = Cassanity::Statement.new(cql)
        ::Cassanity::Future.new driver.execute_async(statement.interpolate(variables))
      end
    end
  end
end
