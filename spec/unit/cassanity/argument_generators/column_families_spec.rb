require 'helper'
require 'cassanity/argument_generators/column_families'

describe Cassanity::ArgumentGenerators::ColumnFamilies do
  describe "#call" do
    context "without keyspace" do
      it "returns array of arguments for selecting all column families" do
        cql = 'SELECT * FROM system.schema_columnfamilies'
        expected = [cql]
        subject.call.should eq(expected)
      end
    end

    context "with :keyspace_name" do
      it "returns array of arguments for selecting all column families for keyspace" do
        cql = 'SELECT * FROM system.schema_columnfamilies WHERE "keyspace_name" = ?'
        variables = ['foo']
        expected = [cql, 'foo']
        subject.call(keyspace_name: 'foo').should eq(expected)
      end
    end
  end
end
