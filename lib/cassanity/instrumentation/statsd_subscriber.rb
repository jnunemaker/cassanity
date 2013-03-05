# Note: You should never need to require this file directly if you are using
# ActiveSupport::Notifications. Instead, you should require the metriks file
# that lives in the same directory as this file. The benefit is that it
# subscribes to the correct events and does everything for your.
require 'cassanity/instrumentation/subscriber'
require 'statsd'

module Cassanity
  module Instrumentation
    class StatsdSubscriber < Subscriber
      class << self
        attr_accessor :client
      end

      def update_timer(metric)
        if self.class.client
          self.class.client.timing metric, @duration
        end
      end
    end
  end
end
