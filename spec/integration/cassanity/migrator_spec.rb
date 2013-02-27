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
        subject.migrate
      end

      it "runs all migrations" do
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
  end

  describe "#ensure_column_family_exists" do
    context "when column family does not exist" do
      before do
        subject.ensure_column_family_exists
      end

      it "creates column family" do
        names = keyspace.column_families.map(&:name)
        string_names = names.map(&:to_s)
        string_names.should include('migrations')
      end
    end

    context "when column family does exist" do
      let(:version) { '1' }

      before do
        # ensure column family exists
        subject.ensure_column_family_exists

        # pretend some migrations exist
        subject.column_family.insert({
          data: {
            version: version,
            name: 'create_users',
            migrated_at: Time.now,
          },
        })

        # ensure column family exists again
        subject.ensure_column_family_exists
      end

      it "does nothing" do
        rows = subject.column_family.select
        rows.size.should be(1)

        row = rows[0]
        row['version'].should eq(version)
        migrated_at = row['migrated_at'].to_i
        migrated_at.should be_within(2).of(Time.now.to_i)
      end
    end
  end
end
