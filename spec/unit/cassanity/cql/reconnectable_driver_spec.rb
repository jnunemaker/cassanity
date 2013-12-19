require 'helper'

describe Cassanity::Cql::ReconnectableDriver do
  let(:client) { double('Cql::Client') }

  describe '.connect' do
    it 'constructs a CQL client using the provided options' do
      Cql::Client.should_receive(:connect).with(:foo => "bar") { client }
      driver = described_class.connect(:foo => "bar")
    end
  end

  describe '#disconnect' do
    it 'closes the underlying driver' do
      Cql::Client.stub(:connect => client)
      driver = described_class.connect(:foo => "bar")

      client.should_receive(:close)
      driver.disconnect
    end
  end

  describe '#use' do
    it 'forwards the message to the underlying driver' do
      Cql::Client.stub(:connect => client)
      driver = described_class.connect(:foo => "bar")

      client.should_receive(:use).with("keyspace")
      driver.use("keyspace")
    end
  end

  describe '#execute' do
    it 'forwards the message to the underlying driver' do
      Cql::Client.stub(:connect => client)
      driver = described_class.connect(:foo => "bar")

      client.should_receive(:execute).with("query")
      driver.execute("query")
    end
  end

  describe '#connected?' do
    it 'forwards the message to the underlying driver' do
      Cql::Client.stub(:connect => client)
      driver = described_class.connect(:foo => "bar")

      client.should_receive(:connected?).and_return(true)
      driver.connected?.should be_true
    end
  end
end
