require 'helper'
require 'cassanity/client'

describe Cassanity::Client do
  let(:driver) { double Cassanity::Drivers::CassandraDriver }

  before do
    # Ensure that we never hit cassandra for real here.
    Cassanity::Drivers::CassandraDriver.stub connect: driver
  end

  describe "#initialize" do
    it "passes arguments to cassandra cql database instance" do
      Cassanity::Drivers::CassandraDriver.should_receive(:connect).
        with(hash_including(hosts: ['localhost'], port: 1234, some: 'option'))

      described_class.new(['localhost'], 1234, some: 'option')
    end

    it "defaults servers if not present" do
      Cassanity::Drivers::CassandraDriver.should_receive(:connect).
        with(hash_including(hosts: ['127.0.0.1'], port: 9042))

      described_class.new
    end

    it "defaults servers if nil" do
      Cassanity::Drivers::CassandraDriver.should_receive(:connect).
        with(hash_including(hosts: ['127.0.0.1'], port: 9042))

      described_class.new(nil)
    end

    it "allows passing instrumenter to executor, but does not pass it to driver instance" do
      instrumenter = double('Instrumenter')
      driver = double('Driver')
      executor = double('Executor')

      Cassanity::Drivers::CassandraDriver.should_receive(:connect).
        with(hash_not_including(instrumenter: instrumenter)).
        and_return(driver)

      Cassanity::Executors::Cassandra.should_receive(:new).
        with(hash_including(driver: driver, instrumenter: instrumenter)).
        and_return(executor)

      described_class.new(['localhost'], 1234, instrumenter: instrumenter)
    end

    it "sets cassandra cql database instance as driver" do
      client = described_class.new
      client.driver.should be_instance_of(driver.class)
    end

    it "builds driver, executor and connection" do
      driver = double('Driver')
      executor = double('Executor')
      connection = double('Connection')

      Cassanity::Drivers::CassandraDriver.should_receive(:connect).and_return(driver)

      Cassanity::Executors::Cassandra.should_receive(:new).
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

  describe "#disconnect" do
    it "allows the connection to be terminated" do
      driver.should_receive(:disconnect)

      client = described_class.new
      client.disconnect
    end
  end

  describe "#connected?" do
    it "returns connected? value for driver" do
      driver.should_receive(:connected?).and_return(true)

      client = described_class.new
      client.connected?.should be_true
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
