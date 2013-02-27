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

    context "when some migrations have been run" do
      before do
        # pretend the first couple migrations have run
        subject.migrated migrations[0]
        subject.migrated migrations[1]

        # run the migrations that need to be
        subject.migrate
      end

      it "runs migrations that need to be run" do
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
end
