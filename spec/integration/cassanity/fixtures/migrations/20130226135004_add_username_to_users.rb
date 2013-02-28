class AddUsernameToUsers < Cassanity::Migration
  def up
    keyspace[:users].alter(add: {username: :text})
  end

  def down
    keyspace[:users].alter(drop: :username)
  end
end
