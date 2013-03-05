# Note: You should never need to require this file directly if you are using
# ActiveSupport::Notifications. Instead, you should require the metriks file
# that lives in the same directory as this file. The benefit is that it
# subscribes to the correct events and does everything for your.
require 'statsd'

module Cassanity
  module Instrumentation
    class StatsdSubscriber
      class << self
        attr_accessor :client
      end

      # Public: Use this as the subscribed block.
      def self.call(name, start, ending, transaction_id, payload)
        new(name, start, ending, transaction_id, payload).update
      end

      # Private: Initializes a new event processing instance.
      def initialize(name, start, ending, transaction_id, payload)
        @name = name
        @start = start
        @ending = ending
        @payload = payload
        @duration = ending - start
        @transaction_id = transaction_id

        @command_name = @payload[:command]
        @keyspace_name = @payload[:keyspace_name]
        @column_family_name = @payload[:column_family_name]
      end

      # Public: Actually update all the metriks timers for the event.
      #
      # Returns nothing.
      def update
        update_timer 'cassanity.cql'

        if command_name?
          update_type_timer :command, @command_name
        end

        if column_family_name?
          update_type_timer :column_family, @column_family_name
        end

        if column_family_name? && command_name?
          update_type_timer :column_family, "#{@column_family_name}.#{@command_name}"
        end
      end

      # Private: Update a timer based on the type and name. This method is very
      # similar to the following:
      #
      #   Metriks.timer('cassanity.command.keyspaces.cql').update(duration).
      def update_type_timer(type, name)
        update_timer "cassanity.#{type}.#{name}.cql"
      end

      # Private: Update a timer based on a full metric name.
      def update_timer(metric)
        client.timing metric, @duration
      end

      # Private: Returns true if command name present else false.
      def command_name?
        @command_name_present ||= !@command_name.nil? && !@command_name.empty?
      end

      # Private: Returns true if column family name present else false.
      def column_family_name?
        @column_family_name_present ||= !@column_family_name.nil? && !@column_family_name.empty?
      end

      # Private: The statsd client to use.
      def client
        self.class.client
      end
    end
  end
end
