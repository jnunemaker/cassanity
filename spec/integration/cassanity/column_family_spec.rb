require 'helper'
require 'cassanity/keyspace'
require 'cassanity/executors/cassandra_cql'

describe Cassanity::ColumnFamily do
  let(:keyspace_name)               { 'cassanity_test' }
  let(:column_family_name)          { 'apps' }
  let(:counters_column_family_name) { 'counters' }

  let(:client) {
    CassandraCQL::Database.new('127.0.0.1:9160', {
      cql_version: '3.0.0',
    })
  }

  let(:keyspace) {
    Cassanity::Keyspace.new({
      name: keyspace_name,
      executor: executor,
    })
  }

  let(:executor) {
    Cassanity::Executors::CassandraCql.new({
      client: client,
    })
  }

  subject {
    described_class.new({
      keyspace: keyspace,
      name: column_family_name,
    })
  }

  before do
    client_drop_keyspace(client, keyspace_name)
    client_create_keyspace(client, keyspace_name)
    client_create_column_family(client, column_family_name, "id text PRIMARY KEY, name text")
    client_create_column_family(client, counters_column_family_name, "id text PRIMARY KEY, views counter")
  end

  after do
    client_drop_keyspace(client, keyspace_name)
  end

  it "can truncate" do
    client.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '1', 'github')
    client.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '2', 'gist')
    result = client.execute("SELECT * FROM #{column_family_name}")
    result.rows.should eq(2)

    subject.truncate

    result = client.execute("SELECT * FROM #{column_family_name}")
    result.rows.should eq(0)
  end

  it "can drop" do
    client_column_family?(client, column_family_name).should be_true
    subject.drop
    client_column_family?(client, column_family_name).should be_false
  end

  it "can insert data" do
    subject.insert({
      data: {
        id: '1',
        name: 'GitHub',
      },
    })

    result = client.execute("SELECT * FROM #{column_family_name}")
    result.rows.should eq(1)
    row = result.fetch_hash
    row['id'].should eq('1')
    row['name'].should eq('GitHub')
  end

  it "can update data" do
    client.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '1', 'github')
    client.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '2', 'gist')

    subject.update({
      set: {name: 'New Name'},
      where: {id: '1'},
    })

    result = client.execute("SELECT * FROM #{column_family_name} WHERE id = '1'")
    result.rows.should eq(1)
    row = result.fetch_hash
    row['id'].should eq('1')
    row['name'].should eq('New Name')

    # does not update other rows
    result = client.execute("SELECT * FROM #{column_family_name} WHERE id = '2'")
    result.rows.should eq(1)
    row = result.fetch_hash
    row['id'].should eq('2')
    row['name'].should eq('gist')
  end

  describe "updating a counter column" do
    subject {
      described_class.new({
        keyspace: keyspace,
        name: counters_column_family_name,
      })
    }

    it "works" do
      subject.update({
        set: {views: 'views + 2'},
        where: {id: '1'},
      })

      result = client.execute("SELECT * FROM #{counters_column_family_name} WHERE id = '1'")
      result.rows.should eq(1)
      row = result.fetch_hash
      row['id'].should eq('1')
      row['views'].should be(2)
    end
  end

  it "can delete data" do
    client.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '1', 'github')
    client.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '2', 'gist')

    result = client.execute("SELECT * FROM #{column_family_name}")
    result.rows.should eq(2)

    subject.delete({
      where: {id: '1'},
    })

    result = client.execute("SELECT * FROM #{column_family_name} WHERE id = '1'")
    result.rows.should eq(0)

    # does not delete other rows
    result = client.execute("SELECT * FROM #{column_family_name} WHERE id = '2'")
    result.rows.should eq(1)
  end
end
