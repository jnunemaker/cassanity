require 'helper'
require 'cassanity/keyspace'
require 'cassanity/executors/cassandra_cql'

describe Cassanity::Keyspace do
  let(:keyspace_name)      { 'cassanity_test' }
  let(:column_family_name) { 'apps' }

  let(:client) {
    CassandraCQL::Database.new('127.0.0.1:9160', {
      cql_version: '3.0.0',
    })
  }

  let(:executor) {
    Cassanity::Executors::CassandraCql.new({
      client: client,
    })
  }

  subject {
    described_class.new({
      name: keyspace_name,
      executor: executor,
    })
  }

  before do
    client_drop_keyspace(client, keyspace_name)
    client_create_keyspace(client, keyspace_name)
  end

  after do
    client_drop_keyspace(client, keyspace_name)
  end

  it "can use" do
    client.execute("USE system")
    client.keyspace.should_not eq(keyspace_name)
    subject.use
    client.keyspace.should eq(keyspace_name)
  end

  it "can drop" do
    client_keyspace?(client, keyspace_name).should be_true
    subject.drop
    client_keyspace?(client, keyspace_name).should be_false
  end
end
