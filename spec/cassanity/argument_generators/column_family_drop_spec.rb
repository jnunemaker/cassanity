require 'helper'
require 'cassanity/argument_generators/column_family_drop'

describe Cassanity::ArgumentGenerators::ColumnFamilyDrop do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    it "returns array of arguments" do
      cql = "DROP COLUMNFAMILY #{column_family_name}"
      expected = [cql]
      subject.call(name: column_family_name).should eq(expected)
    end
  end
end
