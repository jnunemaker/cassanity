class CreateA < Cassanity::Migration
  def up
    create_column_family :a, {
      primary_key: :id,
      columns: { id: :int }
    }
  end

  def down
    drop_column_family :a
  end
end
