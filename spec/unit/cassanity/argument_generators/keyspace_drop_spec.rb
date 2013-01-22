require 'helper'
require 'cassanity/argument_generators/keyspace_drop'

describe Cassanity::ArgumentGenerators::KeyspaceDrop do
  let(:keyspace_name) { 'analytics' }

  describe "#call" do
    it "returns array of arguments" do
      cql = "DROP KEYSPACE #{keyspace_name}"
      expected = [cql]
      subject.call(keyspace_name: keyspace_name).should eq(expected)
    end
  end
end
