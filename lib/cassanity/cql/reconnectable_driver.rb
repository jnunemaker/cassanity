require 'delegate'

module Cassanity
  module Cql
    # Internal: An intermediate driver for cql-rb that supports reconnecting
    # by recycling the underlying Cql::Client instance.
    #
    # Reconnecting is important when using a forking web server like unicorn,
    # but cql-rb does not allow a Cql::Client instances that has been
    # disconnected to be reconnected.
    class ReconnectableDriver
      extend Forwardable
      def_delegators :@driver, :use, :execute, :keyspace

      def self.connect(cql_options = {})
        new(cql_options).tap(&:connect)
      end

      # cql_options: Options for constructing a Cql::Client
      def initialize(cql_options = {})
        @cql_options = cql_options
      end

      def connect
        disconnect
        @driver = ::Cql::Client.connect(@cql_options)
      end

      def disconnect
        @driver.close if @driver
      end
    end
  end
end
