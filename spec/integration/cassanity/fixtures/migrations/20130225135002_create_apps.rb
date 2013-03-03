class CreateApps < Cassanity::Migration
  def up
    create_column_family :apps, {
      primary_key: :id,
      columns: {
        id: :timeuuid,
        name: :text,
      },
    }
  end

  def down
    drop_column_family :apps
  end
end
