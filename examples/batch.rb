require_relative '_shared'
require 'cassanity'

client = Cassanity::Client.new('127.0.0.1:9160', logger: Logger.new(STDOUT))
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

# passing in keyspace and column family names by default
default_arguments = {
  keyspace_name: keyspace.name,
  name: apps.name,
}

# batch several operations in one network call
client.batch({
  modifications: [
    [:insert, default_arguments.merge(data: {id: '1', name: 'github'})],
    [:insert, default_arguments.merge(data: {id: '2', name: 'gist'})],
    [:update, default_arguments.merge(set: {name: 'github.com'}, where: {id: '1'})],
    [:delete, default_arguments.merge(where: {id: '2'})],
  ],
})

# only github.com is left
pp apps.select
