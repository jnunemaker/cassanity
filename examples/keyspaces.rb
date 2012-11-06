require_relative '_shared'
require 'cassanity'

client = CassandraCQL::Database.new('127.0.0.1:9160')
executor = Cassanity::Executors::CassandraCql.new(client: client)

connection = Cassanity::Connection.new(executor: executor)

# gets instance of keyspace
keyspace = connection['cassanity_examples']

# or you can do this...
keyspace = connection.keyspace('cassanity_examples')

pp keyspace

# you can also provide options
keyspace = connection.keyspace('cassanity_examples', {
  strategy_class: 'SimpleStrategy',
  strategy_options: {
    replication_factor: 1,
  },
})

# drop keyspace if it exists
keyspace.drop if connection.keyspace?('cassanity_examples')

# create the keyspace, uses options from above
keyspace.create

# use this keyspace
keyspace.use

# get an instance of a column family
apps = keyspace.column_family('apps')

# you can also pass a schema so the column family is all knowing
apps_schema = Cassanity::Schema.new({
  primary_key: :id,
  columns: {
    id: :text,
    name: :text,
  },
})

apps = keyspace.column_family('apps', {
  schema: apps_schema,
})
pp apps

# that was basically just a shortcut for this
apps = Cassanity::ColumnFamily.new({
  name: 'apps',
  keyspace: keyspace,
  schema: apps_schema,
})
pp apps
