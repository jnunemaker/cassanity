class CreateB < Cassanity::Migration
  def up
    create_column_family :b, {
      primary_key: :id,
      columns: { id: :int }
    }
  end

  def down
    drop_column_family :b
  end
end
