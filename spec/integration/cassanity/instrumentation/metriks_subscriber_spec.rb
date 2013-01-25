require 'helper'
require 'cassanity/instrumentation/metriks'

describe Cassanity::Instrumentation::MetriksSubscriber do
  let(:client) {
    Cassanity::Client.new('127.0.0.1:9160', {
      instrumenter: ActiveSupport::Notifications,
    })
  }

  let(:keyspace) { client[:cassanity_test] }

  let(:column_family) {
    keyspace.column_family({
      name: :apps,
      schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          name: :text,
        },
      },
    })
  }

  before do
    keyspace.recreate
    column_family.recreate
  end

  it "updates timers when cql calls happen" do
    # Clear the registry so we don't count the operations required to re-create
    # the keyspace and column family.
    Metriks::Registry.default.clear

    column_family.insert({
      data: {
        id: SimpleUUID::UUID.new,
        name: 'GitHub.com',
      },
    })

    Metriks.timer('cassanity.cql').count.should be(1)
    Metriks.timer('cassanity.column_family.apps.cql').count.should be(1)
    Metriks.timer('cassanity.command.column_family_insert.cql').count.should be(1)
    Metriks.timer('cassanity.column_family.apps.column_family_insert.cql').count.should be(1)
  end
end
