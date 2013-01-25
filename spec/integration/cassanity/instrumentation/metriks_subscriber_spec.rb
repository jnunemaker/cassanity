require 'helper'
require 'securerandom'
require 'active_support/notifications'
require 'cassanity/instrumentation/metriks_subscriber'

describe Cassanity::Instrumentation::MetriksSubscriber do
  let(:client) {
    Cassanity::Client.new(nil, {
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
    keyspace.create unless keyspace.exists?
    column_family.create unless column_family.exists?

    @subscriber = ActiveSupport::Notifications.subscribe(
                    'cql.cassanity',
                    described_class
                  )
  end

  after do
    ActiveSupport::Notifications.unsubscribe(@subscriber)
  end

  it "updates timers when cql calls happen" do
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
