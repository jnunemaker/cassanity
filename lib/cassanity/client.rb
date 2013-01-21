require 'forwardable'
require 'cassandra-cql'
require 'cassanity/executors/cassandra_cql'
require 'cassanity/connection'

module Cassanity
  class Client
    extend Forwardable

    # Public: The instance of the CassandraCQL::Database being used.
    attr_reader :driver

    # Public: The instance of the Cassanity::Executors::CassandraCQL that will
    # execute all queries.
    attr_reader :executor

    # Public: The instance of the Cassanity::Connection that is the entry point
    # for all operations.
    attr_reader :connection

    # Public: Initialize an instance of the client.
    #
    # servers - The String or Array of Strings representing the servers to
    #           connect to.
    # options - The Hash of CassandraCQL::Database options.
    # thrift_options - The Hash of CassandraCQL::Database thrift client options.
    def initialize(servers = nil, options = {}, thrift_options = {})
      servers ||= '127.0.0.1:9160'
      options = options.dup
      options[:cql_version] ||= '3.0.0'
      logger = options.delete(:logger)

      @driver = CassandraCQL::Database.new(servers, options, thrift_options)

      @executor = Cassanity::Executors::CassandraCql.new({
        client: @driver,
        logger: logger,
      })

      @connection = Cassanity::Connection.new({
        executor: @executor,
      })
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
