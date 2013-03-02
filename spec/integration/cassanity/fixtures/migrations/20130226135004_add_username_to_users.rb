class AddUsernameToUsers < Cassanity::Migration
  def up
    add_column :users, :username, :text
  end

  def down
    drop_column :users, :username
  end
end
