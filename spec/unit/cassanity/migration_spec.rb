require 'helper'
require 'cassanity/migration'

describe Cassanity::Migration do
  describe "#initialize" do
    it "sets keyspace" do
      keyspace = double('Keyspace')
      instance = described_class.new(keyspace)
      instance.keyspace.should be(keyspace)
    end
  end
end
