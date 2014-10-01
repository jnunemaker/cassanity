# Migrations

Cassanity comes with a migrations framework similar to ActiveRecord. Because not everyone will need migrations, you must require it in addition like so:

```ruby
require 'cassanity/migrator'
```
## Creating Your First Migration

Out of the box, Cassanity comes with no generators for migrations. Fear not, if you can create a file, you can create a migration. For example, let's say that you would like to create a users column family.

First, create the directory that will house your migrations.

```bash
mkdir -p db/migrate
```

Second, create a file for the create users migration:

```bash
touch db/migrate/`date +%s`_create_users.rb
```

This will create a file with the current timestamp as the prefix. This is the recommended naming convention.

Now, open the file up in your favorite editor and paste in the following:

```ruby
class CreateUsers < Cassanity::Migration
  def up
    create_column_family :users, {
      primary_key: :id,
      columns: {
        id: :timeuuid,
        name: :text,
        age: :int,
        updated_at: :timestamp,
      },
    }
  end

  def down
    drop_column_family :users
  end
end
```

If you have ever used Active Record's migrations, the previous migration file should look really familiar. Instead of going for a fancy DSL, like AR's, the convenience methods you get are just a very thing layer on top of Cassanity itself.

The available convenience methods are:

* `create_column_family(column_family_name, schema)` - aliased to add_column_family, create_table and add_table
* `drop_column_family(column_family_name)` - aliased to drop_table
* `add_column(column_family_name, column_name, type)` - shortcut for alter_column_family with add
* `drop_column(column_family_name, column_name)` - shortcut for alter_column_family with drop
* `alter_column_family(column_family_name, args)` - args are passed straight through to ColumnFamily#alter.
* `add_index(column_family_name, column_name, options = {})` - create a cassandra secondary index; aliased to create_index
* `drop_index(column_family_name, index_name)` - drop a cassandra secondary index
* `say_with_time(message) { # do something }` - spit a message out to the migrators log, time the duration of the block, and also spit out the duration upon finished execution of the block
* `say(message)` - spit a message out to the migrator's log

You can always check out the [source](https://github.com/jnunemaker/cassanity/blob/master/lib/cassanity/migration.rb) or [specs](https://github.com/jnunemaker/cassanity/blob/master/spec/integration/cassanity/migration_spec.rb) for more about these methods.

## Running migrations

The act of running migrations is performed by a migrator. To migrate all pending migrations, simply call migrate:

```ruby
require 'pathname'
require 'cassanity/migrator'

# Assuming the keyspace is already created.
keyspace = Cassanity::Client.new[:my_app]

# Path to our migrations directory.
migrations_path = Pathname(__FILE__).dirname.join('db', 'migrate')

# Create a migrator instance.
migrator = Cassanity::Migrator.new(keyspace, migrations_path)

# Run all the pending migrations, in this instance create_users.
migrator.migrate
```

You can run `migrator.migrate` over and over and it will only run migrations that have not yet been performed.

In addition to `migrate`, you can also `migrate_to` a specific version in a direction.

```ruby
# assuming the same setup as the above example

# migrate all the way back to nothing
migrator.migrate_to(0, :down)

# migrate our users migration again
migrator.migrate_to(1, :up)
```

**Note**: When migrating up, the version you declared is included. However, when migrating down, it does not migrate down the version provided.

```ruby
# run all migrations that have not been performed
migrator.migrate

# invoke the down method of all performed migrations with version > 1
# note that down will not be invoked for migrations with version of 1
migrator.migrate_to(1, :down)

# invoke the down method for all performed migrations
migrator.migrate_to(0, :down)

# invoke the up method for migrations with version <= 1
# note that up will be invoked for migrations with version of 1
migrator.migrate_to(1, :up)
```

**Note**: Migrations will run in the order they appear on disk (alphanumerically sorted), that's why we encourage you to use timestamped migrations.

## Rake Tasks

What is that? You want some rake tasks to handle migrating? [Here is a gist for that](https://gist.github.com/jnunemaker/5086063). I will try to keep it up to date and I am definitely open to any solutions that would make integrating all of this with your app easier.
