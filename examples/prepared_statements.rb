require_relative '_shared'
require 'cassanity'

client = Cassanity::Client.new(['127.0.0.1'], 9160, {
  instrumenter: ActiveSupport::Notifications,
})

keyspace = client['cassanity_examples']
keyspace.recreate

# setting up the apps column family
apps = keyspace.column_family('apps', {
  schema: {
    primary_key: :id,
    columns: {
      id: :text,
      name: :text,
    },
  },
})
apps.create

# prepare the statement. 
prepared_insert = apps.prepare_insert fields: [:id, :name]

# run the prepared statements with several different values
# This method is much efficient for bulk inserts than normal insert
# statements as skips all parsing and validation in the Cassandra cluster.
prepared_insert.execute id: '1', name: 'GitHub'
prepared_insert.execute id: '2', name: 'GitHub-1'
prepared_insert.execute id: '3', name: 'GitHub-2'

# All inserted apps are found
pp apps.select