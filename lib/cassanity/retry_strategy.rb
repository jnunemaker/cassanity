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
      def execute(payload = nil)
        return unless block_given?

        attempt = 0

        while attempt += 1
          begin
            payload[:attempts] = attempt unless payload.nil?
            return yield
          rescue CassandraCQL::Error::InvalidRequestException => e
            fail(attempt, e)
          end
        end
      end
    end
  end
end