# Note: You should never need to require this file directly if you are using
# ActiveSupport::Notifications. Instead, you should require the metriks file
# that lives in the same directory as this file. The benefit is that it
# subscribes to the correct events and does everything for your.
require 'cassanity/instrumentation/subscriber'
require 'metriks'

module Cassanity
  module Instrumentation
    class MetriksSubscriber < Subscriber
      def update_timer(metric)
        Metriks.timer(metric).update(@duration)
      end
    end
  end
end
