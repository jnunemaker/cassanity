module Cassanity
  module RetryStrategies
    class RetryNTimes
      attr_reader :retries
      attr_reader :tries_so_far

      def initialize(args = {})
        # By default, there's no retry behavior at all - if the call fails, you
        # get the error propagated to you.
        @retries = args[:retries] || 0
      end

      def execute_with_retry(driver, execute_args)
        @tries_so_far = 0

        while @tries_so_far <= @retries do
          begin
            return driver.execute(*execute_args)
          rescue StandardError => e
            # TODO: log something for each failure, or increment a metrics counter
            # so we can see how often calls fail and require a retry.
            @tries_so_far += 1
            if @tries_so_far > @retries
              raise
            end
          end
        end
      end
    end
  end
end