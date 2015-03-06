require 'delegate'

module Cassanity
  module Drivers
    # Internal: An intermediate driver for cassandra-ruby that merges the
    # behavior of the cluster and the session in one single object
    class CassandraDriver
      extend Forwardable
      def_delegators :session, :execute, :keyspace, :prepare

      def self.connect(cql_options = {})
        new(cql_options).tap(&:connect)
      end

      # cql_options: Options for constructing a Cql::Client
      def initialize(cql_options = {})
        @cql_options = cql_options
      end

      def connect
        @driver = Cassandra.cluster @cql_options
      end

      def use(keyspace)
        @session = @driver.connect keyspace.to_s
      end

      def session
        @session ||= @driver.connect
      end

    end
  end
end
