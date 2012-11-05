require 'helper'
require 'cassanity/argument_generators/keyspaces'

describe Cassanity::ArgumentGenerators::Keyspaces do
  describe "#call" do
    it "returns array of arguments" do
      cql = "SELECT * FROM system.schema_keyspaces"
      expected = [cql]
      subject.call.should eq(expected)
    end
  end
end
