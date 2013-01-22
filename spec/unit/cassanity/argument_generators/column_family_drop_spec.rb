require 'helper'
require 'cassanity/argument_generators/column_family_drop'

describe Cassanity::ArgumentGenerators::ColumnFamilyDrop do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    it "returns array of arguments" do
      cql = "DROP COLUMNFAMILY #{column_family_name}"
      expected = [cql]
      subject.call(column_family_name: column_family_name).should eq(expected)
    end

    context "with :keyspace_name" do
      it "returns array of arguments" do
        cql = "DROP COLUMNFAMILY foo.#{column_family_name}"
        expected = [cql]
        subject.call({
          keyspace_name: :foo,
          column_family_name: column_family_name
        }).should eq(expected)
      end
    end
  end
end
