require 'logger'
require 'securerandom'
require 'active_support/notifications'
require 'active_support/log_subscriber'

module Cassanity
  module ExampleInstrumentation
    class LogSubscriber < ::ActiveSupport::LogSubscriber
      def cql(event)
        return unless logger.debug?

        name = '%s (%.1fms)' % ["CQL Query", event.duration]
        cql, *args = event.payload[:execute_arguments]
        arguments = args.map { |arg| arg.inspect }.join(', ')
        query = "#{cql}"
        query += " (#{arguments})" unless arguments.empty?

        debug "  #{color(name, CYAN, true)}  [ #{query} ]"
      end
    end
  end
end

ActiveSupport::LogSubscriber.logger = Logger.new(STDOUT)

Cassanity::ExampleInstrumentation::LogSubscriber.attach_to :cassanity
