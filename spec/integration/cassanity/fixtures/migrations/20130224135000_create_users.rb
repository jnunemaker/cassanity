class CreateUsers < Cassanity::Migration
  def up
    column_family.create
  end

  def down
    column_family.drop
  end

  def column_family
    keyspace.column_family({
      name: :users,
      schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          name: :text,
          age: :int,
          updated_at: :timestamp,
        },
      },
    })
  end
end
