require 'cassanity/retry_strategy'

module Cassanity
  module RetryStrategies
    class RetryNTimes < RetryStrategy
      # Private
      attr_reader :retries

      # Public: initialize the retry strategy.
      #
      # args - The Hash of arguments.
      #        :retries - the number of times to retry an unsuccessful call
      #                   before failing.
      def initialize(args = {})
        # By default, there's no retry behavior at all - if the call fails, you
        # get the error propagated to you.
        @retries = args[:retries] || 0
      end

      # Private: re-raise the exception from the last call if it's been retried
      # more than the maximum amount of retries.
      def fail(attempts, error)
        if attempts > @retries
          raise error
        end
      end
    end
  end
end