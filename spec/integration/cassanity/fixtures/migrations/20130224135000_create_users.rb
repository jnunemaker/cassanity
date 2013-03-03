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
