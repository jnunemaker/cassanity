require 'helper'
require 'cassanity/argument_generators/keyspace_create'

describe Cassanity::ArgumentGenerators::KeyspaceCreate do
  let(:keyspace_name) { :analytics }

  describe "#call" do
    context "only name" do
      it "returns array of arguments" do
        cql = "CREATE KEYSPACE #{keyspace_name} WITH strategy_class = ? AND strategy_options:replication_factor = ?"
        expected = [cql, 'SimpleStrategy', 1]
        subject.call(keyspace_name: keyspace_name).should eq(expected)
      end
    end

    context "overriding strategy_class" do
      it "returns array of arguments" do
        cql = "CREATE KEYSPACE #{keyspace_name} WITH strategy_class = ? AND strategy_options:replication_factor = ?"
        expected = [cql, 'FooStrategy', 1]
        subject.call({
          keyspace_name: keyspace_name,
          strategy_class: 'FooStrategy',
        }).should eq(expected)
      end
    end

    context "overriding a default strategy_option" do
      it "returns array of arguments" do
        cql = "CREATE KEYSPACE #{keyspace_name} WITH strategy_class = ? AND strategy_options:replication_factor = ?"
        expected = [cql, 'SimpleStrategy', 3]
        subject.call({
          keyspace_name: keyspace_name,
          strategy_options: {
            replication_factor: 3,
          }
        }).should eq(expected)
      end
    end

    context "adding new strategy_option" do
      it "returns array of arguments" do
        cql = "CREATE KEYSPACE #{keyspace_name} WITH strategy_class = ? AND strategy_options:replication_factor = ? AND strategy_options:batman = ?"
        expected = [cql, 'SimpleStrategy', 1, 'robin']
        subject.call({
          keyspace_name: keyspace_name,
          strategy_options: {
            batman: 'robin',
          }
        }).should eq(expected)
      end
    end
  end
end
