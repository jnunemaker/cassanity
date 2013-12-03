require 'helper'
require 'cassanity/migrator'

describe Cassanity::Migration do
  let(:client) { Cassanity::Client.new(CassanityHost, CassanityPort) }
  let(:driver) { client.driver }
  let(:keyspace) { client[:cassanity_test] }
  let(:migrator) { Cassanity::Migrator.new(keyspace, '/fake') }
  let(:migration) { Class.new(described_class).new(migrator) }

  before do
    driver_drop_keyspace(driver, keyspace.name)
    driver_create_keyspace(driver, keyspace.name)
  end

  describe "#create_column_family" do
    before do
      migration.create_column_family(:users, {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          name: :text,
          age: :int,
        },
      })
    end

    it "creates a column family" do
      keyspace[:users].exists?.should be_true
    end
  end

  describe "#drop_column_family" do
    before do
      keyspace.column_family(:users, schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          name: :text,
          age: :int,
        },
      }).create

      migration.drop_column_family :users
    end

    it "drops column family" do
      keyspace[:users].exists?.should be_false
    end
  end

  describe "#add_column" do
    before do
      keyspace.column_family(:users, schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          name: :text,
          age: :int,
        },
      }).create

      migration.add_column :users, :email, :text
    end

    it "adds column" do
      columns = keyspace[:users].columns
      column = columns.detect { |column| column.name == :email }
      column.should_not be_nil
      column.type.should be(:text)
    end
  end

  describe "#drop_column" do
    before do
      keyspace.column_family(:users, schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          name: :text,
          age: :int,
        },
      }).create

      migration.drop_column :users, :age
    end

    it "drops column" do
      columns = keyspace[:users].columns
      column = columns.detect { |column| column.name == :age }
      column.should be_nil
    end
  end

  describe "#alter_column_family" do
    before do
      keyspace.column_family(:users, schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          name: :text,
          age: :int,
        },
      }).create

      migration.alter_column_family :users, drop: :age
    end

    it "alters the column family" do
      columns = keyspace[:users].columns
      column = columns.detect { |column| column.name == :age }
      column.should be_nil
    end
  end

  describe "#add_index" do
    before do
      keyspace.column_family(:users, schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          email: :text,
        },
      }).create

      migration.add_index :users, :email, name: :users_email_index
    end

    it "adds index" do
      columns = driver.execute("SELECT * from system.schema_columns WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='users' ALLOW FILTERING")
      index = columns.detect { |c| c['index_name'] == 'users_email_index' }
      index.should_not be_nil
    end
  end

  describe "#drop_index" do
    before do
      column_family = keyspace.column_family(:users, schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          email: :text,
        },
      })
      column_family.create
      column_family.create_index(column_name: :email, name: :users_email_index)

      migration.drop_index :users, :users_email_index
    end

    it "drops index" do
      columns = driver.execute("SELECT * from system.schema_columns WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='users' ALLOW FILTERING")
      index = columns.detect { |c| c['index_name'] == 'users_email_index' }
      index.should be_nil
    end
  end
end
