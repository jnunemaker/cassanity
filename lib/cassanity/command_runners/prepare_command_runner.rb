module Cassanity
  module CommandRunners
    class PrepareCommandRunner < ExecuteCommandRunner
      def run(driver, cql, variables)
        driver.prepare(cql)
      end
    end
  end
end
