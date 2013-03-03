require 'helper'
require 'cassanity/keyspace'

describe Cassanity::Keyspace do
  let(:keyspace_name)              { 'cassanity_test' }
  let(:self_created_keyspace_name) { 'self_created' }
  let(:column_family_name)         { 'apps' }

  let(:client) { Cassanity::Client.new(CassanityServers) }
  let(:driver) { client.driver }

  let(:required_arguments) {
    {
      name: keyspace_name,
      executor: client.executor,
    }
  }

  subject {
    described_class.new(required_arguments)
  }

  before do
    driver_drop_keyspace(driver, keyspace_name)
    driver_create_keyspace(driver, keyspace_name)
  end

  after do
    driver_drop_keyspace(driver, keyspace_name)
    driver_drop_keyspace(driver, self_created_keyspace_name)
  end

  it "can create" do
    driver_keyspace?(driver, self_created_keyspace_name).should be_false
    instance = described_class.new(required_arguments.merge({
      name: self_created_keyspace_name,
    }))
    instance.create
    driver_keyspace?(driver, self_created_keyspace_name).should be_true
  end

  it "knows if it exists" do
    subject.exists?.should be_true
    driver_drop_keyspace(driver, keyspace_name)
    subject.exists?.should be_false
  end

  it "can recreate when not created" do
    driver_drop_keyspace(driver, keyspace_name)
    driver_keyspace?(driver, keyspace_name).should be_false
    subject.recreate
    driver_keyspace?(driver, keyspace_name).should be_true
  end

  it "can recreate when already created" do
    driver_keyspace?(driver, keyspace_name).should be_true
    subject.recreate
    driver_keyspace?(driver, keyspace_name).should be_true
  end

  it "can use" do
    driver.execute("USE system")
    driver.keyspace.should_not eq(keyspace_name)
    subject.use
    driver.keyspace.should eq(keyspace_name)
  end

  it "can drop" do
    driver_keyspace?(driver, keyspace_name).should be_true
    subject.drop
    driver_keyspace?(driver, keyspace_name).should be_false
  end

  it "knows column families" do
    driver_create_column_family(driver, :something1)
    driver_create_column_family(driver, :something2)

    result = subject.column_families
    result.each do |column_family|
      column_family.should be_instance_of(Cassanity::ColumnFamily)
      column_family.keyspace.should eq(subject)
    end

    names = result.map(&:name)
    names.should include(:something1)
    names.should include(:something2)

    driver_drop_column_family(driver, :something1)
    driver_drop_column_family(driver, :something2)
  end
end
