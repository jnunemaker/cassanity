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

  let(:log_string) { StringIO.new }

  subject {
    described_class.new(keyspace, migrations_path, {
      logger: Logger.new(log_string),
    })
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
        @result[:performed].size.should be(3)
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
        versions = @result[:performed].map(&:version)
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
        versions = @result[:performed].map(&:version)
        versions.should eq([subject.migrations[1].version])
      end
    end
  end

  describe "#migrate_to" do
    context "migrating to specific versions" do
      it "works" do
        subject.migrate_to(subject.migrations[0].version)
        subject.performed_migrations.size.should be(1)

        subject.migrate_to(subject.migrations[1].version)
        subject.performed_migrations.size.should be(2)

        subject.migrate_to(subject.migrations[2].version)
        subject.performed_migrations.size.should be(3)

        subject.migrate_to(subject.migrations[1].version, :down)
        subject.performed_migrations.size.should be(2)

        subject.migrate_to(subject.migrations[0].version, :down)
        subject.performed_migrations.size.should be(1)

        subject.migrate_to(subject.migrations[0].version - 1, :down)
        subject.performed_migrations.size.should be(0)
      end

      it "returns migrations in the order they were performed" do
        result = subject.migrate_to(subject.migrations[2].version)
        result[:performed].map(&:version).should eq([
          subject.migrations[0].version,
          subject.migrations[1].version,
          subject.migrations[2].version,
        ])

        result = subject.migrate_to(0, :down)
        result[:performed].map(&:version).should eq([
          subject.migrations[2].version,
          subject.migrations[1].version,
          subject.migrations[0].version,
        ])
      end
    end
  end

  describe "#migrated" do
    it "adds migration to performed migrations" do
      migration = subject.migrations[0]
      subject.migrated(migration)
      names = subject.column_family.select.map { |row| row['name'] }
      names.should include(migration.name)
    end
  end

  describe "#unmigrated" do
    it "removes migration from performed migrations" do
      migration = subject.migrations[0]
      subject.column_family.insert(data: {
        version: migration.version,
        name: migration.name,
        migrated_at: Time.now,
      })
      subject.unmigrated(migration)
      names = subject.column_family.select.map { |row| row['name'] }
      names.should_not include(migration.name)
    end
  end

  describe "#migrations" do
    it "returns all migrations in order from the migrations path" do
      names = subject.migrations.map(&:name)
      names.should eq([
        'create_users',
        'create_apps',
        'add_username_to_users',
      ])
    end
  end

  describe "#performed_migrations" do
    it "returns all performed migrations in order" do
      subject.migrations.each do |migration|
        subject.column_family.insert(data: {
          name: migration.name,
          version: migration.version,
          migrated_at: Time.now,
        })
      end

      names = subject.performed_migrations.map(&:name)
      names.should eq([
        'create_users',
        'create_apps',
        'add_username_to_users',
      ])
    end
  end

  describe "#pending_migrations" do
    it "returns all pending migrations in order" do
      migration = subject.migrations[0]
      subject.column_family.insert(data: {
        name: migration.name,
        version: migration.version,
        migrated_at: Time.now,
      })
      names = subject.pending_migrations.map(&:name)
      names.should eq([
        'create_apps',
        'add_username_to_users',
      ])
    end
  end

  describe "#log" do
    it "sends message to logger" do
      subject.log('just testing')
      log_string.string.should match("just testing")
    end
  end
end
