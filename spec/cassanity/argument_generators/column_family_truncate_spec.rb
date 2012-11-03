require 'helper'
require 'cassanity/argument_generators/column_family_truncate'

describe Cassanity::ArgumentGenerators::ColumnFamilyTruncate do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    it "returns array of arguments" do
      cql = "TRUNCATE #{column_family_name}"
      expected = [cql]
      subject.call(name: column_family_name).should eq(expected)
    end
  end
end
