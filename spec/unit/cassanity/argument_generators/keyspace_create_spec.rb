require 'helper'
require 'cassanity/argument_generators/keyspace_create'

describe Cassanity::ArgumentGenerators::KeyspaceCreate do
  let(:keyspace_name) { :analytics }

  describe "#call" do
    context "only name" do
      it "returns array of arguments" do
        cql = "CREATE KEYSPACE #{keyspace_name} WITH replication = ?"
        expected = [cql, {class: 'SimpleStrategy', replication_factor: 1}]
        subject.call(keyspace_name: keyspace_name).should eq(expected)
      end
    end

    context "overriding replication class" do
      it "returns array of arguments" do
        cql = "CREATE KEYSPACE #{keyspace_name} WITH replication = ?"
        expected = [cql, {class: 'FooStrategy', replication_factor: 1}]
        subject.call({
          keyspace_name: keyspace_name,
          replication: {class: 'FooStrategy'},
        }).should eq(expected)
      end
    end

    context "overriding a default strategy_option" do
      it "returns array of arguments" do
        cql = "CREATE KEYSPACE #{keyspace_name} WITH replication = ?"
        expected = [cql, {class: 'SimpleStrategy', replication_factor: 3}]
        subject.call({
          keyspace_name: keyspace_name,
          replication: {replication_factor: 3},
        }).should eq(expected)
      end
    end

    context "adding new strategy_option" do
      it "returns array of arguments" do
        cql = "CREATE KEYSPACE #{keyspace_name} WITH replication = ?"
        expected = [cql, {class: 'SimpleStrategy', replication_factor: 1, batman: 'robin'}]
        subject.call({
          keyspace_name: keyspace_name,
          replication: {batman: 'robin'},
        }).should eq(expected)
      end
    end
  end
end
