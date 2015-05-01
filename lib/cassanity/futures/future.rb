
module Cassanity
  class Future

    attr_reader :internal_future
    attr_accessor :result_transformer

    def initialize(future)
      @internal_future = future
    end

    # Public: Waits until all the given futures finish
    #
    # futures - Array of all the futures to wait for.
    def self.wait_all(futures)
      results = Cassandra::Future.all(futures.map(&:internal_future)).get if futures.any?
      futures.zip(results).map do |future, result|
        if future.result_transformer
          future.result_transformer.call result
        else
          result
        end
      end
    end

    # Public: Waits for the wrapped query to finish
    def wait
      result = @internal_future.get
      result_transformer.call result if result_transformer
    end
  end
end
