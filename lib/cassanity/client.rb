require 'forwardable'
require 'cql'
require 'cassanity/executors/cql_rb'
require 'cassanity/connection'

module Cassanity
  class Client
    extend Forwardable

    # Public: The instance of the Cql::Client being used.
    attr_reader :driver

    # Public: The instance of the Cassanity::Executors::CqlRb that will
    # execute all queries.
    attr_reader :executor

    # Public: The instance of the Cassanity::Connection that is the entry point
    # for all operations.
    attr_reader :connection

    # Public: Initialize an instance of the client.
    #
    # servers - The String or Array of Strings representing the servers to
    #           connect to.
    # port - The Integer representing the port to connect to Cassandra with.
    #        This must be the same for all hosts.
    # options - The Hash of Cql::Client options.
    #   :default_consistency - default consistency for the connection
    #   (if not specified, set to :quorum)
    def initialize(servers = nil, port = nil, options = {})
      servers ||= ['127.0.0.1']
      port    ||= 9042

      @options        = options.merge(hosts: servers, port: port)
      @instrumenter   = @options.delete(:instrumenter)
      @retry_strategy = @options.delete(:retry_strategy)

      connect
    end

    # Connect or reconnect to cassandra
    def connect
      disconnect

      @driver = Cql::Client.connect(@options)
      @executor = Cassanity::Executors::CqlRb.new({
        driver: @driver,
        instrumenter: @instrumenter,
        retry_strategy: @retry_strategy,
      })
      @connection = Cassanity::Connection.new({
        executor: @executor,
      })
    end

    # Disconnect from cassandra.
    def disconnect
      @driver.close if @driver
    end

    # Methods on client that should be delegated to connection.
    DelegateToConnectionMethods = [
      :keyspaces,
      :keyspace,
      :[],
      :batch,
    ]

    def_delegators :@connection, *DelegateToConnectionMethods

    # Public
    def inspect
      attributes = [
        "driver=#{driver.inspect}",
        "executor=#{executor.inspect}",
        "connection=#{connection.inspect}",
      ]
      "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
    end
  end
end
