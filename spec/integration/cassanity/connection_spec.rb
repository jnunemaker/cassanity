require 'helper'
require 'cassanity/connection'
require 'cassanity/executors/cassandra_cql'

describe Cassanity::Connection do
  let(:keyspace_name)      { 'cassanity_test' }
  let(:column_family_name) { 'apps' }

  let(:client) { Cassanity::Client.new }
  let(:driver) { client.driver }

  subject { client.connection }

  before do
    driver_drop_keyspace(driver, keyspace_name)
  end

  after do
    driver_drop_keyspace(driver, keyspace_name)
  end

  it "can batch" do
    driver_create_keyspace(driver, keyspace_name)
    driver_create_column_family(driver, column_family_name, "id text PRIMARY KEY, name text")

    subject.batch({
      keyspace_name: keyspace_name,
      column_family_name: column_family_name,
      :modifications => [
        [:insert, data: {id: '1', name: 'github'}],
        [:insert, data: {id: '2', name: 'gist'}],
        [:update, set: {name: 'github.com'}, where: {id: '1'}],
        [:delete, where: {id: '2'}],
      ]
    })

    result = driver.execute("SELECT * FROM apps")
    result.rows.should be(1)

    rows = []
    result.fetch_hash { |row| rows << row }

    rows.should eq([
      {'id' => '1', 'name' => 'github.com'},
    ])
  end

  it "knows keyspaces" do
    driver_create_keyspace(driver, 'something1')
    driver_create_keyspace(driver, 'something2')

    result = subject.keyspaces
    result.each do |keyspace|
      keyspace.should be_instance_of(Cassanity::Keyspace)
      keyspace.executor.should eq(subject.executor)
    end

    names = result.map(&:name)
    names.should include('something1')
    names.should include('something2')

    driver_drop_keyspace(driver, 'something1')
    driver_drop_keyspace(driver, 'something2')
  end
end
