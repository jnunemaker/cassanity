module CassanityHelpers
  def driver_keyspace?(driver, name)
    rows = driver.execute("SELECT keyspace_name FROM system.schema_keyspaces WHERE keyspace_name='#{name}' ALLOW FILTERING")
    rows.to_a.any?
  end

  def driver_create_keyspace(driver, name)
    unless driver_keyspace?(driver, name)
      driver.execute("CREATE KEYSPACE #{name} WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 1 }")
    end
    driver.use(name)
  end

  def driver_drop_keyspace(driver, name)
    if driver_keyspace?(driver, name)
      driver.execute("DROP KEYSPACE #{name}")
    end
  end

  def driver_column_family?(driver, name)
    rows = driver.execute("SELECT columnfamily_name FROM system.schema_columnfamilies WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='#{name}' ALLOW FILTERING")
    rows.to_a.any?
  end

  def driver_create_column_family(driver, name, columns = nil)
    columns ||= "id text PRIMARY KEY, name text"
    unless driver_column_family?(driver, name)
      driver.execute("CREATE COLUMNFAMILY #{name} (#{columns})")
    end
  end

  def driver_drop_column_family(driver, name)
    if driver_column_family?(driver, name)
      driver.execute("DROP COLUMNFAMILY #{name}")
    end
  end

  def cassandra_error(err)
    Cql::CqlError.new(err)
  end
end
