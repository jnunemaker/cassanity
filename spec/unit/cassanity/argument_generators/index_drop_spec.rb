require 'helper'
require 'cassanity/argument_generators/index_drop'

describe Cassanity::ArgumentGenerators::IndexDrop do
  describe "#call" do
    it "returns array of arguments" do
      cql = "DROP INDEX mutants_ability_id"
      expected = [cql]
      subject.call({
        :name => :mutants_ability_id,
      }).should eq(expected)
    end
  end
end
