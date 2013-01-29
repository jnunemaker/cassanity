require 'securerandom'
require 'active_support/notifications'
require 'active_support/log_subscriber'

module Cassanity
  module Instrumentation
    class LogSubscriber < ::ActiveSupport::LogSubscriber
      def cql(event)
        return unless logger.debug?

        name = '%s (%.1fms)' % ["CQL Query", event.duration]

        cql = event.payload[:cql]
        vars = event.payload[:cql_variables] || []
        variables = vars.map { |var| var.inspect }.join(', ')

        query = "#{cql}"
        query += " (#{variables})" unless variables.empty?

        debug "  #{color(name, CYAN, true)}  [ #{query} ]"
      end
    end
  end
end

Cassanity::Instrumentation::LogSubscriber.attach_to :cassanity
