require 'securerandom'
require 'active_support/notifications'
require 'cassanity/instrumentation/metriks_subscriber'

ActiveSupport::Notifications.subscribe 'cql.cassanity',
  Cassanity::Instrumentation::MetriksSubscriber
