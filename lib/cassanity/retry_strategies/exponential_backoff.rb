require 'cassanity/retry_strategies/retry_strategy'

module Cassanity
  module RetryStrategies
    class ExponentialBackoff < RetryStrategy
      # Taken from https://github.com/twitter/kestrel-client's blocking client.
      SLEEP_TIMES = [[0] * 1, [0.01] * 2, [0.1] * 2, [0.5] * 2, [1.0] * 1].flatten

      # Private: the maxmimum number of times to retry or -1 to try forever.
      attr_reader :retries

      # Public: Initialize the retry strategy.
      #
      # args   - The Hash of options.
      #          :retries - the maximum number of times to retry or -1 to try
      #                     forever.
      def initialize(args = {})
        # The default behavior is to retry forever.
        @retries = args[:retries] || -1
      end

      def fail(attempts, error)
        if @retries >= 0 && attempts > @retries
          raise error
        end
        sleep_for_count(attempts)
      end

      # Private: sleep a randomized amount of time from the
      # SLEEP_TIMES mostly-exponential distribution.
      #
      # count - the index into the distribution to pull the base sleep time from
      def sleep_for_count(count)
        base = SLEEP_TIMES[count] || SLEEP_TIMES.last

        time = ((rand * base) + base) / 2
        sleep time if time > 0
      end
    end
  end
end
