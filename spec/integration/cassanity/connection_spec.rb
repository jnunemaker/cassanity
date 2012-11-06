require 'helper'
require 'cassanity/connection'
require 'cassanity/executors/cassandra_cql'

describe Cassanity::Connection do
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
      executor: executor,
    })
  }

  before do
    client_drop_keyspace(client, keyspace_name)
  end

  after do
    client_drop_keyspace(client, keyspace_name)
  end

  it "can batch" do
    client_create_keyspace(client, keyspace_name)
    client_create_column_family(client, column_family_name, "id text PRIMARY KEY, name text")

    default_arguments = {
      keyspace_name: keyspace_name,
      name: column_family_name,
    }

    subject.batch({
      :modifications => [
        [:insert, default_arguments.merge(data: {id: '1', name: 'github'})],
        [:insert, default_arguments.merge(data: {id: '2', name: 'gist'})],
        [:update, default_arguments.merge(set: {name: 'github.com'}, where: {id: '1'})],
        [:delete, default_arguments.merge(where: {id: '2'})],
      ]
    })

    result = client.execute("SELECT * FROM apps")
    result.rows.should be(1)

    rows = []
    result.fetch_hash { |row| rows << row }

    rows.should eq([
      {'id' => '1', 'name' => 'github.com'},
    ])
  end

  it "knows keyspaces" do
    client_create_keyspace(client, 'something1')
    client_create_keyspace(client, 'something2')

    result = subject.keyspaces
    result.each do |keyspace|
      keyspace.should be_instance_of(Cassanity::Keyspace)
      keyspace.executor.should eq(subject.executor)
    end

    names = result.map(&:name)
    names.should include('something1')
    names.should include('something2')

    client_drop_keyspace(client, 'something1')
    client_drop_keyspace(client, 'something2')
  end

  it "knows if a keyspace exists" do
    subject.keyspace?(keyspace_name).should be_false
    client_create_keyspace(client, keyspace_name)
    subject.keyspace?(keyspace_name).should be_true
  end
end
