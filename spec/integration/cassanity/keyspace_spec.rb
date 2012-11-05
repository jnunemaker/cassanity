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

  it "can create a column family" do
    schema = Cassanity::Schema.new({
      primary_key: :id,
      columns: {
        id: :timeuuid,
        name: :text,
      },
      with: {
        comment: 'For storing things',
      }
    })

    subject.create_column_family({
      name: column_family_name,
      schema: schema,
    })

    client.schema.column_family_names.should include(column_family_name)
    apps_column_family = client.schema.column_families[column_family_name]
    apps_column_family.comment.should eq('For storing things')
    columns = apps_column_family.columns
    columns.should have_key('id')
    columns.should have_key('name')
    columns['id'].should eq('org.apache.cassandra.db.marshal.TimeUUIDType')
    columns['name'].should eq('org.apache.cassandra.db.marshal.UTF8Type')
  end
end
