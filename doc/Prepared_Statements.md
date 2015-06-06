# Prepared statements

Cassanity supports prepared statements while still maintaining the Cassanity style.

Prepared statements are a highly recommended Cassandra feature to use when you plan to execute
the same statement several times across different values. The biggest benefit of this feature is
saving parsing time, as the statement will be prepared (parsed) just once in its lifetime.

All operations are susceptible of being prepared, but Cassanity currently only supports
preparing INSERT and SELECT statements (the most used ones).

To prepare a statement we first need a reference to the column family object that will receive the statement.

```ruby
client = Cassanity::Client.new(['127.0.0.1'], 9160, {
  instrumenter: ActiveSupport::Notifications,
})

keyspace = client['cassanity_examples']
keyspace.recreate

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
```

## Prepared SELECT

Then we can prepare the SELECT statement. Prepared select statements are pretty much
the same as normal select statements except that you should:

1. Indicate which fields will be varying across the different executions
2. Which is the type of each varying field from the previous step.


```ruby
prepared_select = apps.prepare_select({
  select: :name,
  where: {
    id: Cassanity::SingleFieldPlaceholder.new
  }
})
```

Here we are preparing a select statement to retrieve the `name` field and we have
configured it to use a clause with the field `id`. Also we have said that the field
`id` will be compared against single values (i.e. `id = '34'`)

Finally we just need to execute it against the desired values of the variable.

```ruby

results = prepared_select.execute id: '34'
pp results
```

Currently Cassanity supports:

* SingleFieldPlaceholder: for one to one comparisons `field = value`
* RangePlaceholder: for range comparisons like `field >= value1 AND field < value2`
* ArrayPlaceholder: for array comparisons like `field IN (value1, ... , valuen)`

## Prepared INSERT

In the case of prepared inserts we just need to specify which fields will receive
values.

```ruby
prepared_insert = apps.prepare_insert fields: [:id, :name]
```

Here we have prepared an insert statement that will receive different values
for both the id and name fields for every execution.

```ruby
prepared_insert.execute id: '1', name: 'GitHub'
prepared_insert.execute id: '2', name: 'GitHub-1'
prepared_insert.execute id: '3', name: 'GitHub-2'
```

You can see a full working example here: [examples/prepared_statements.rb](https://github.com/jnunemaker/cassanity/tree/master/examples/prepared_statements.rb)


