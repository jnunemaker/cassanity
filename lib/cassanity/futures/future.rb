
module Cassanity
  class Future
    extend Forwardable

    attr_reader :internal_future

    def_delegators :@internal_future, :get, :on_complete

    def initialize(future)
      @internal_future = future
    end

    # Public: Waits until all the given futures finish
    #
    # futures - Array of all the futures to wait for.
    def self.wait_all(futures)
      Cassandra::Future.all(futures.map(&:internal_future)).get if futures.any?
    end

    # Public: Waits for the wrapped query to finish
    alias_method :wait, :get
  end
end
