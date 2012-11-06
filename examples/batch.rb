require_relative '_shared'
require 'cassanity'

client = CassandraCQL::Database.new('127.0.0.1:9160')
executor = Cassanity::Executors::CassandraCql.new(client: client)

connection = Cassanity::Connection.new(executor: executor)
keyspace = connection['cassanity_examples']
keyspace.drop if connection.keyspace?('cassanity_examples')
keyspace.create

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
connection.batch({
  modifications: [
    [:insert, default_arguments.merge(data: {id: '1', name: 'github'})],
    [:insert, default_arguments.merge(data: {id: '2', name: 'gist'})],
    [:update, default_arguments.merge(set: {name: 'github.com'}, where: {id: '1'})],
    [:delete, default_arguments.merge(where: {id: '2'})],
  ],
})

# only github.com is left
pp apps.select
