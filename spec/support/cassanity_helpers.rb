module CassanityHelpers
  def client_keyspace?(client, name)
    client.keyspaces.map(&:name).include?(name.to_s)
  end

  def client_create_keyspace(client, name)
    unless client_keyspace?(client, name)
      client.execute("CREATE KEYSPACE #{name} WITH strategy_class = 'SimpleStrategy' AND strategy_options:replication_factor = 1")
    end
    client.execute("USE #{name}")
  end

  def client_drop_keyspace(client, name)
    if client_keyspace?(client, name)
      client.execute("DROP KEYSPACE #{name}")
    end
  end

  def client_column_family?(client, name)
    client.schema.column_family_names.include?(name.to_s)
  end

  def client_create_column_family(client, name, columns = nil)
    columns ||= "id text PRIMARY KEY, name text"
    unless client_column_family?(client, name)
      client.execute("CREATE COLUMNFAMILY #{name} (#{columns})")
    end
  end

  def client_drop_column_family(client, name)
    if client_column_family?(client, name)
      client.execute("DROP COLUMNFAMILY #{name}")
    end
  end
end
