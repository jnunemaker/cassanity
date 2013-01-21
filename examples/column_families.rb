require_relative '_shared'
require 'cassanity'

client = Cassanity::Client.new('127.0.0.1:9160', logger: Logger.new(STDOUT))

keyspace = client['cassanity_examples']
keyspace.recreate

apps_schema = Cassanity::Schema.new({
  primary_key: :id,
  columns: {
    id: :text,
    name: :text,
  },
})

# get an instance of a column family, providing schema means it can create itself
apps = keyspace.column_family('apps', schema: apps_schema)

# create column family based on schema
apps.create

# insert a row
apps.insert(data: {id: '1', name: 'GitHub'})

# insert another row
apps.insert(data: {id: '2', name: 'Gist'})

# select rows from apps
pp apps.select

# update a row based on id
apps.update(set: {name: 'GitHub.com'}, where: {id: '1'})

# print out the rows again, note that GitHub is updated
pp apps.select

# now we add a timestamp column
apps.alter(add: {updated_at: :timestamp})

# note that updated_at is there now, but nil
pp apps.select

apps.update(set: {updated_at: Time.now}, where: {id: '1'})

# now the GitHub.com record has an updated_at
pp apps.select

# delete all data
apps.truncate

# now all the data is gone
pp apps.select

# completely drop the column family
apps.drop

begin
  # we can no longer insert because the column family is gone
  apps.insert(data: {id: '1', name: 'FAILBOAT'})

# All errors inherit from Cassanity::Error so you can catch everything easily
rescue Cassanity::Error => e
  puts "\n\nError should be raised here."
  puts e.inspect
end
