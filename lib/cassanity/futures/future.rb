
module Cassanity
  class Future
    extend Forwardable

    def_delegators :@future, :get, :on_complete

    def initialize(future)
      @future = future
    end
  end
end
