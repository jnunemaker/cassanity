require_relative '_shared'
require 'cassanity'

client = Cassanity::Client.new('127.0.0.1:9160', {
  instrumenter: ActiveSupport::Notifications,
})

keyspace = client['cassanity_examples']
keyspace.recreate

rollups_schema = Cassanity::Schema.new({
  primary_key: [:id, :timestamp],
  columns: {
    id: :text,
    timestamp: :int,
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

[
  [1, rand(1_000)],
  [2, rand(1_000)],
  [3, rand(1_000)],
  [4, rand(1_000)],
  [5, rand(1_000)],
].each do |pair|
  timestamp, value = pair
  rollups.update({
    set: {value: Cassanity::Increment.new(value)},
    where: {
      id: :views,
      timestamp: timestamp,
    }
  })
end

# returns timestamps 1, 2 and 3
pp rollups.select({
  where: {
    id: :views,
    timestamp: Range.new(1, 3),
  }
})

# also works with exclusion of end ranges
# returns 1 and 2
pp rollups.select({
  where: {
    id: :views,
    timestamp: Range.new(1, 3, true),
  }
})

# also works with operators
# returns 3, 4 and 5
pp rollups.select({
  where: {
    id: :views,
    timestamp: Cassanity::Operator.new(:>, 2),
  }
})

# returns 2, 3, 4 and 5
pp rollups.select({
  where: {
    id: :views,
    timestamp: Cassanity::Operator.new(:>=, 2),
  }
})

puts "\n\n ALL BELOW SHOULD RETURN 1 \n\n"

# returns 1
pp rollups.select({
  where: {
    id: :views,
    timestamp: Cassanity::Operator.new(:<, 2),
  }
})

# returns 1
pp rollups.select({
  where: {
    id: :views,
    timestamp: Cassanity::Operators::Lt.new(2),
  }
})

# returns 1
pp rollups.select({
  where: {
    id: :views,
    timestamp: Cassanity::Operators::Lt(2),
  }
})

# returns 1
pp rollups.select({
  where: {
    id: :views,
    timestamp: Cassanity.lt(2),
  }
})
