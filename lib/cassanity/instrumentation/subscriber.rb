module Cassanity
  module Instrumentation
    class Subscriber
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

      # Private
      def update_type_timer(type, name)
        update_timer "cassanity.#{type}.#{name}.cql"
      end

      # Internal: Override in subclass.
      def update_timer(metric)
        raise 'not implemented'
      end

      # Private: Returns true if command name present else false.
      def command_name?
        @command_name_present ||= !@command_name.nil? && !@command_name.empty?
      end

      # Private: Returns true if column family name present else false.
      def column_family_name?
        @column_family_name_present ||= !@column_family_name.nil? && !@column_family_name.empty?
      end
    end
  end
end
