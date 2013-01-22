require_relative '_shared'
require 'cassanity'

client = Cassanity::Client.new('127.0.0.1:9160', {
  instrumenter: ActiveSupport::Notifications,
})

keyspace = client['cassanity_examples']
keyspace.recreate

# setting up the apps column family
apps_schema = Cassanity::Schema.new({
  primary_key: :id,
  columns: {
    id: :text,
    name: :text,
  },
})
apps = keyspace.column_family('apps', schema: apps_schema)
apps.create

# batch several operations in one network call
client.batch({
  keyspace_name: keyspace.name,
  column_family_name: apps.name,
  modifications: [
    [:insert, data: {id: '1', name: 'github'}],
    [:insert, data: {id: '2', name: 'gist'}],
    [:update, set: {name: 'github.com'}, where: {id: '1'}],
    [:delete, where: {id: '2'}],
  ],
})

# only github.com is left
pp apps.select
