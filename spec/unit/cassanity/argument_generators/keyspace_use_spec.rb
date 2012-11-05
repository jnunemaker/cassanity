require 'helper'
require 'cassanity/argument_generators/keyspace_use'

describe Cassanity::ArgumentGenerators::KeyspaceUse do
  let(:keyspace_name) { 'analytics' }

  describe "#call" do
    it "returns array of arguments" do
      cql = "USE #{keyspace_name}"
      expected = [cql]
      subject.call(name: keyspace_name).should eq(expected)
    end
  end
end
