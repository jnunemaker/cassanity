require 'helper'

describe Cassanity::Drivers::CassandraDriver do
  let(:client) { double Cassandra::Cluster }

  describe '.connect' do
    it 'constructs a Cassandra::Cluster using the provided options' do
      Cassandra.should_receive(:cluster).with foo: 'bar'
      described_class.connect foo: 'bar'
    end
  end

  context 'once connected' do

    let(:driver) { described_class.connect }
    let(:session) { double Cassandra::Session }

    before do
      Cassandra.stub cluster: client
      client.stub connect: session
    end

    describe '#use' do
      it 'forwards the message to the underlying driver' do
        session.should_receive(:execute).with 'USE keyspace'
        driver.use 'keyspace'
      end
    end

    describe '#session' do
      it 'initializes a new session with no keyspace' do
        client.should_receive(:connect).with no_args
        driver.session
      end

      it 'reuses session if already exists' do
        client.should_receive(:connect).with(no_args).once.and_return(session)
        driver.session
        driver.session
      end
    end

    describe '#execute' do

      it 'forwards the message to the underlying driver' do
        session.should_receive(:execute).with 'query'
        driver.execute 'query'
      end
    end

    describe '#disconnect' do
      it 'closes the underlying driver' do
        client.should_receive :close
        driver.disconnect
      end
    end
  end
end
