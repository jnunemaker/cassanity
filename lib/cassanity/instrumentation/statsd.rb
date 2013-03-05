require 'securerandom'
require 'active_support/notifications'
require 'cassanity/instrumentation/statsd_subscriber'

ActiveSupport::Notifications.subscribe 'cql.cassanity',
  Cassanity::Instrumentation::StatsdSubscriber
