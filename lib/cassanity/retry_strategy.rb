module Cassanity
  module RetryStrategies
    class RetryStrategy
      # Internal: override in subclass.
      #
      # attempts    - how many times the unsuccessful call has been tried so far
      # last_error  - the error raised by the unsuccessful call
      def fail(attempts, last_error)
        raise 'not implemented'
      end

      # Public: execute the given block, and handle errors raised
      # by the CassandraCQL driver. Call the retry method (overridden in your
      # subclass) on each failed attempt with a current retry count and
      # the error raised by the block.
      def execute
        return unless block_given?

        attempt = 0
        while attempt += 1
          begin
            return yield
          rescue CassandraCQL::Error::InvalidRequestException => e
            # TODO: log something for each failure, or increment a metrics counter
            # so we can see how often calls fail and require a retry.
            fail(attempt, e)
          end
        end
      end
    end
  end
end