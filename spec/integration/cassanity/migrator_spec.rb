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

        version_to_name = {
          '20130224135000' => 'create_users',
          '20130225135002' => 'create_apps',
          '20130226135004' => 'add_username_to_users',
        }

        rows.each do |row|
          version_to_name.fetch(row['version']).should eq(row['name'])
        end
      end

      it "executes migrations" do
        keyspace[:users].exists?.should be_true
        keyspace[:apps].exists?.should be_true
      end
    end

    context "when some migrations have been run" do
      before do
        subject.migrate_to subject.migrations[1].version
        @result = subject.migrate
      end

      it "runs only migrations that need to be" do
        versions = @result[:ran_migrations].map(&:version)
        versions.should eq([subject.migrations[2].version])
      end
    end

    context "when migration has not been run that is older than migrations that have been run" do
      before do
        subject.migrated subject.migrations[0]
        subject.migrated subject.migrations[2]
        @result = subject.migrate
      end

      it "runs migration that has not been run" do
        versions = @result[:ran_migrations].map(&:version)
        versions.should eq([subject.migrations[1].version])
      end
    end
  end

  describe "#migrate_to" do
    context "migrating to specific versions" do
      it "works" do
        subject.migrate_to(subject.migrations[0].version)
        subject.ran_migrations.size.should be(1)

        subject.migrate_to(subject.migrations[1].version)
        subject.ran_migrations.size.should be(2)

        subject.migrate_to(subject.migrations[2].version)
        subject.ran_migrations.size.should be(3)

        subject.migrate_to(subject.migrations[1].version, :down)
        subject.ran_migrations.size.should be(2)

        subject.migrate_to(subject.migrations[0].version, :down)
        subject.ran_migrations.size.should be(1)

        subject.migrate_to(subject.migrations[0].version - 1, :down)
        subject.ran_migrations.size.should be(0)
      end
    end
  end
end
