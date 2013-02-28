require 'helper'
require 'cassanity/migrator'

describe Cassanity::Migrator do
  let(:client) { Cassanity::Client.new(CassanityServers) }
  let(:driver) { client.driver }
  let(:keyspace) { client[:cassanity_test] }
  let(:column_family) { subject.column_family }

  let(:migrations_path) {
    Pathname(__FILE__).dirname.join('fixtures', 'migrations')
  }

  let(:migrations) {
    Cassanity::Migration::Collection.from_path(migrations_path)
  }

  subject {
    described_class.new(keyspace, migrations_path)
  }

  before do
    driver_drop_keyspace(driver, keyspace.name)
    driver_create_keyspace(driver, keyspace.name)
  end

  describe "#migrate" do
    context "when no migrations have been run" do
      before do
        @result = subject.migrate
      end

      it "runs all migrations" do
        @result[:ran_migrations].size.should be(3)
      end

      it "stores migrations in column family" do
        rows = column_family.select
        rows.size.should be(3)

        create_users_row = rows.detect { |row|
          row['name'] == 'create_users'
        }
        create_users_row.should_not be_nil
        create_users_row['version'].should eq('20130224135000')

        create_apps = rows.detect { |row|
          row['name'] == 'create_apps'
        }
        create_apps.should_not be_nil
        create_apps['version'].should eq('20130225135002')

        add_username_to_users = rows.detect { |row|
          row['name'] == 'add_username_to_users'
        }
        add_username_to_users.should_not be_nil
        add_username_to_users['version'].should eq('20130226135004')
      end
    end

    context "when some migrations have been run" do
      before do
        subject.migrated migrations[0]
        subject.migrated migrations[1]

        @result = subject.migrate
      end

      it "runs only migrations that need to be" do
        versions = @result[:ran_migrations].map(&:version)
        versions.should eq([migrations[2].version])
      end
    end

    context "when migration has not been run that is older than migrations that have been run" do
      before do
        subject.migrated migrations[0]
        subject.migrated migrations[2]
        @result = subject.migrate
      end

      it "runs migration that has not been run" do
        versions = @result[:ran_migrations].map(&:version)
        versions.should eq([migrations[1].version])
      end
    end
  end

  describe "#migrate_to" do
    context "migrating to specific versions" do
      it "works" do
        subject.migrate_to(migrations[0].version)
        subject.ran_migrations.size.should be(1)

        subject.migrate_to(migrations[1].version)
        subject.ran_migrations.size.should be(2)

        subject.migrate_to(migrations[2].version)
        subject.ran_migrations.size.should be(3)

        subject.migrate_to(migrations[1].version, :down)
        subject.ran_migrations.size.should be(2)

        subject.migrate_to(migrations[0].version, :down)
        subject.ran_migrations.size.should be(1)

        subject.migrate_to(migrations[0].version - 1, :down)
        subject.ran_migrations.size.should be(0)
      end
    end
  end
end
