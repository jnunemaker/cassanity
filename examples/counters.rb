require_relative '_shared'
require 'cassanity'

client = CassandraCQL::Database.new('127.0.0.1:9160', {
  cql_version: '3.0.0',
})

executor = Cassanity::Executors::CassandraCql.new({
  client: client,
  logger: Logger.new(STDOUT),
})

connection = Cassanity::Connection.new(executor: executor)
keyspace = connection['cassanity_examples']
keyspace.recreate

rollups_schema = Cassanity::Schema.new({
  primary_key: :id,
  columns: {
    id: :text,
    value: :counter,
  },
})

# get an instance of a column family, providing schema means it can create itself
rollups = keyspace.column_family({
  name: :rollups,
  schema: rollups_schema,
})

# create column family based on schema
rollups.create

# increment by 1
rollups.update({
  set:   {value: Cassanity::Increment.new},
  where: {id: :views},
})

# increment by 3
rollups.update({
  set:   {value: Cassanity::Increment.new(3)},
  where: {id: :views},
})

# increment by 3
rollups.update({
  set:   {value: Cassanity::Increment(3)},
  where: {id: :views},
})

# increment by 3
# you can also use .incr and .increment
rollups.update({
  set:   {value: Cassanity.inc(3)},
  where: {id: :views},
})

# returns 10
pp rollups.select(where: {id: :views})[0]['value']

# decrement by 1
rollups.update({
  set:   {value: Cassanity::Decrement.new},
  where: {id: :views},
})

# decrement by 2
rollups.update({
  set:   {value: Cassanity::Decrement.new(2)},
  where: {id: :views},
})

# decrement by 2
rollups.update({
  set:   {value: Cassanity::Decrement(2)},
  where: {id: :views},
})

# decrement by 2
# you can also use .decr and .decrement
rollups.update({
  set:   {value: Cassanity.dec(2)},
  where: {id: :views},
})

# returns 3
pp rollups.select(where: {id: :views})[0]['value']

keyspace.drop
