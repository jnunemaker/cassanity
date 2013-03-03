require 'helper'
require 'cassanity/argument_generators/columns'

describe Cassanity::ArgumentGenerators::Columns do
  describe "#call" do
    context "with no args" do
      it "returns array of arguments for selecting all columns" do
        cql = 'SELECT * FROM system.schema_columns'
        expected = [cql]
        subject.call.should eq(expected)
      end
    end

    context "with keyspace" do
      it "returns array of arguments for selecting all columns for keyspace" do
        cql = 'SELECT * FROM system.schema_columns WHERE "keyspace" = ?'
        expected = [cql, 'foo']
        subject.call({
          keyspace_name: 'foo',
        }).should eq(expected)
      end
    end

    context "with column family" do
      it "returns array of arguments for selecting all columns for column family" do
        cql = 'SELECT * FROM system.schema_columns WHERE "columnfamily" = ?'
        expected = [cql, 'foo']
        subject.call({
          column_family_name: 'foo',
        }).should eq(expected)
      end
    end

    context "with keyspace and column family" do
      it "returns array of arguments for selecting all columns for a column family in a keyspace" do
        cql = 'SELECT * FROM system.schema_columns WHERE "keyspace" = ? AND "columnfamily" = ?'
        expected = [cql, 'foo', 'bar']
        subject.call({
          keyspace_name: 'foo',
          column_family_name: 'bar',
        }).should eq(expected)
      end
    end
  end
end
