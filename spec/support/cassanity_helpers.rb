module CassanityHelpers
  def driver_keyspace?(driver, name)
    driver.keyspaces.map(&:name).include?(name.to_s)
  end

  def driver_create_keyspace(driver, name)
    unless driver_keyspace?(driver, name)
      driver.execute("CREATE KEYSPACE #{name} WITH strategy_class = 'SimpleStrategy' AND strategy_options:replication_factor = 1")
    end
    driver.execute("USE #{name}")
  end

  def driver_drop_keyspace(driver, name)
    if driver_keyspace?(driver, name)
      driver.execute("DROP KEYSPACE #{name}")
    end
  end

  def driver_column_family?(driver, name)
    driver.schema.column_family_names.include?(name.to_s)
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
end
