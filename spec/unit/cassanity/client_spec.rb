require 'helper'
require 'cassanity/client'

describe Cassanity::Client do
  describe "#initialize" do
    it "passes arguments to cassandra cql database instance" do
      CassandraCQL::Database.should_receive(:new).
        with(
          'localhost:1234',
          hash_including(some: 'option'),
          instance_of(Hash)
        )

      described_class.new('localhost:1234', some: 'option')
    end

    it "defaults servers if not present" do
      CassandraCQL::Database.should_receive(:new).
        with(
          '127.0.0.1:9160',
          instance_of(Hash),
          instance_of(Hash)
        )

      described_class.new
    end

    it "defaults servers if nil" do
      CassandraCQL::Database.should_receive(:new).
        with(
          '127.0.0.1:9160',
          instance_of(Hash),
          instance_of(Hash)
        )

      described_class.new(nil)
    end

    it "defaults cql version in options to 3" do
      CassandraCQL::Database.should_receive(:new).
        with(
          anything,
          hash_including(cql_version: '3.0.0'),
          instance_of(Hash)
        )

      described_class.new
    end

    it "does not override cql version option if other options are provided" do
      CassandraCQL::Database.should_receive(:new).
        with(
          anything,
          hash_including(cql_version: '3.0.0', some: 'thing'),
          instance_of(Hash)
        )

      described_class.new('localhost:1234', some: 'thing')
    end

    it "allows passing instrumenter to executor, but does not pass it to driver instance" do
      instrumenter = double('Instrumenter')
      driver = double('Driver')
      executor = double('Executor')

      CassandraCQL::Database.should_receive(:new).
        with(
          anything,
          hash_not_including(instrumenter: instrumenter),
          instance_of(Hash)
        ).
        and_return(driver)

      Cassanity::Executors::CassandraCql.should_receive(:new).
        with(driver: driver, instrumenter: instrumenter).
        and_return(executor)

      described_class.new('localhost:1234', instrumenter: instrumenter)
    end

    it "sets cassandra cql database instance as driver" do
      client = described_class.new
      client.driver.should be_instance_of(CassandraCQL::Database)
    end

    it "builds driver, executor and connection" do
      driver = double('Driver')
      executor = double('Executor')
      connection = double('Connection')

      CassandraCQL::Database.should_receive(:new).and_return(driver)

      Cassanity::Executors::CassandraCql.should_receive(:new).
        with(hash_including(driver: driver)).
        and_return(executor)

      Cassanity::Connection.should_receive(:new).
        with(executor: executor).
        and_return(connection)

      client = described_class.new

      client.driver.should be(driver)
      client.executor.should be(executor)
      client.connection.should be(connection)
    end
  end

  describe "#keyspaces" do
    it "delegates to connection" do
      keyspace = double('Keyspace')
      keyspaces = [keyspace]
      client = described_class.new
      client.connection.stub(:keyspaces => keyspaces)
      client.keyspaces.should be(keyspaces)
    end
  end

  describe "#keyspace" do
    it "delegates to connection" do
      keyspace = double('Keyspace')
      client = described_class.new
      client.connection.stub(:keyspace => keyspace)
      client.keyspace(:foo).should be(keyspace)
    end
  end

  describe "#[]" do
    it "delegates to connection" do
      keyspace = double('Keyspace')
      client = described_class.new
      client.connection.stub(:[] => keyspace)
      client[:foo].should be(keyspace)
    end
  end

  describe "#batch" do
    it "delegates to connection" do
      modifications = [[:insert, :stuff]]

      client = described_class.new
      client.connection.should_receive(:batch).
        with(modifications).
        and_return(:booyeah)

      client.batch(modifications)
    end
  end

  describe "#inspect" do
    it "return representation" do
      result = subject.inspect
      result.should match(/#{described_class}/)
      result.should match(/driver=/)
      result.should match(/executor=/)
      result.should match(/connection=/)
    end
  end
end
