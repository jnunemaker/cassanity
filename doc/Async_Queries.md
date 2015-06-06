# Asynchronous Queries

Cassanity supports asynchronous queries.

Asynchronous queries allow you to throw several queries at once and have them run
concurrently in the cluster without having to worry about any of the challenges
that concurrent programming exposes.

The driver will be responsible for running them in parallel and notify your
callbacks when they finish. It'll be also responsible for balancing the
load among the available nodes.

All queries are susceptible of being run asynchronously, but currently
Cassanity only supports `INSERT` and `SELECT` (the most used ones).

To execute queries asynchronously we first need a reference to the column family
that will receive the query.

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

## Asynchronous SELECT

To asynchronously run a `SELECT` statement we just need to invoke the corresponding method (`select_async`)

```ruby
future = apps.select_async({
  select: :name,
  where: {
    id: '2',
  },
})
```

The asynchronous query returns a `Cassanity::Future` object where you can attach
a callback or simply asynchronously `wait` for it.

```ruby
pp future.wait
```

`Cassanity::Future#wait` will return the same result that you would have
received if you had executed the query synchronously.

The biggest benefits of asynchronously querying can be seen when running several
queries at once:

```ruby
futures = (1..100).map do |i|
  apps.select_async({
    select: :name,
    where: {
      id: i.to_s,
    },
  })
end

results = Cassanity::Future.wait_all futures
```

Here we show `Cassanity::Future.wait_all` method which comes handy when waiting
for a bunch of queries to be executed before continuing (and getting results).

## Asynchronous INSERT

Executing `INSERT` statements asynchronously is pretty much the same as
the `SELECT` examples seen before.

Run the query with the appropriate (`_async`) method and wait for the future to execute.

```ruby
future = apps.insert_async id: '1', name: 'GitHub'
future.wait
```

Or do it with a bunch of them

```ruby
futures = (1..100).map do |i|
  apps.insert_async id: i.to_s, name: "App-#{i}"
end
Cassanity::Future.wait_all futures
```

## Asynchronous Prepared Statements

Yes, this will boost your app's performance!!

Prepared statements also have it's own asynchronous variant (`_async`).

```ruby
prepared_select = apps.prepare_select({
  select: :name,
  where: {
    id: Cassanity::SingleFieldPlaceholder.new
  }
})

future = prepared_select.execute_async id: '2'

pp future.wait
```

