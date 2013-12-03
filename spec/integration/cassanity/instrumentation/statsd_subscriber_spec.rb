require 'helper'
require 'simple_uuid'
require 'cassanity/instrumentation/statsd'

describe Cassanity::Instrumentation::StatsdSubscriber do
  let(:statsd_client) { Statsd.new }
  let(:socket) { FakeUDPSocket.new }

  let(:client) {
    Cassanity::Client.new(CassanityHost, CassanityPort, {
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
    described_class.client = statsd_client
    keyspace.recreate
    column_family.recreate
    Thread.current[:statsd_socket] = socket
  end

  after do
    described_class.client = nil
    Thread.current[:statsd_socket] = nil
  end

  it "updates timers when cql calls happen" do
    # Clear the socket so we don't count the operations required to re-create
    # the keyspace and column family.
    socket.clear

    column_family.insert({
      data: {
        id: SimpleUUID::UUID.new,
        name: 'GitHub.com',
      },
    })

    socket.recv.first.should match(/cassanity\.cql\:\d+\|ms/)
    socket.recv.first.should match(/cassanity\.command\.column_family_insert\.cql\:\d+\|ms/)
    socket.recv.first.should match(/cassanity\.column_family\.apps\.cql\:\d+\|ms/)
    socket.recv.first.should match(/cassanity\.column_family.apps.column_family_insert.cql\:\d+\|ms/)
  end
end
