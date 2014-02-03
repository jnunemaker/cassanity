require_relative '_shared'
require 'cassanity'

client = Cassanity::Client.new(['127.0.0.1'], 9042, {
  instrumenter: ActiveSupport::Notifications,
})

keyspace = client['cassanity_examples']
keyspace.recreate

# setup column family
users = keyspace.column_family('users', {
  schema: {
    primary_key: :id,
    columns: {
      id: :text,
      emails: :"set<text>",
      top_places: :"list<text>",
      todo: :"map<timestamp,text>",
    },
  },
})
users.create


## Sets

# insert a row
users.insert(data: {id: '1', emails: Set.new(['f@baggings.com','baggins@gmail.com'])})

# add an element to the set
users.update(set: {emails: Cassanity.inc(Set.new(['a@b.com']))}, where: {id: '1'})

# delete an element from the set
users.update(set: {emails: Cassanity.dec(Set.new(['f@baggings.com']))}, where: {id: '1'})

# delete all elements from the set
users.delete(columns: :emails, where: {id: '1'})
# or
users.update(set: {emails: Set.new}, where: {id: '1'})


## Lists

# insert a row
users.insert(data: {id: '2', top_places: ['mordor','rivendell','rohan']})

# add an element to the list
users.update(set: {top_places: Cassanity.inc(['the shire'])}, where: {id: '2'})

# update an element by its index
users.update(set: {top_places: Cassanity.CollectionItem(0,'riddermark')}, where: {id: '2'})

# delete an element or more from the list
users.update(set: {top_places: Cassanity.dec(['riddermark', 'rivendell'])}, where: {id: '2'})
# or delete an element by its index
users.delete(columns: Hash[:top_places, 0], where: {id: '2'})

# delete all elements from the list
users.delete(columns: :top_places, where: {id: '2'})
# or
users.update(set: {top_places: []}, where: {id: '2'})


## Maps
require 'date'
today = Date.today
tomorrow = today + 1

# insert a row
users.insert(data: {id: '3', todo: {today.to_time => 'enter mordor'}})

# add/update an element to the map
users.update(set: {todo: Cassanity.CollectionItem(tomorrow.to_time, 'find water')}, where: {id: '3'})

# delete an element from the map
users.delete(columns: Hash[:todo, tomorrow.to_time], where: {id: '3'})
# or delete many by index
users.delete(columns: Hash[:todo, [today.to_time, tomorrow.to_time]], where: {id: '3'})

# delete all elements from the map
users.delete(columns: :todo, where: {id: '3'})
# or
users.update(set: {todo: {}}, where: {id: '3'})