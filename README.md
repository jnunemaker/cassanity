# Cassanity

Layer of goodness on top of cassandra-cql so you do not have to write CQL strings all over the place.

Current status: Incomplete and changing fast. **Do not use this yet**, but feel free to follow along.

## Installation

Add this line to your application's Gemfile:

    gem 'cassanity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cassanity

## Usage

```ruby
require 'cassanity'

# cassandra-cql connection
client = CassandraCQL::Database.new('127.0.0.1:9160', {
  cql_version: '3.0.0',
})

# what is going to execute the cql queries?
executor = Cassanity::Executors::CassandraCql.new({
  client: client,
})

# setup connection with something that can execute queries
connection = Cassanity::Connection.new({
  executor: executor,
})

# get keyspace instance
keyspace = connection[:my_app]

# get column family instance
apps = keyspace[:apps]

apps.insert({
  data: {
    id: '1',
    name: 'GitHub.com',
    created_at: Time.now,
  }
})

apps.truncate
apps.drop

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
