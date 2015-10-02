namespace :cassanity do

  def display_migrations(migrations)
    max_size = (migrations.map(&:name).map(&:size).max || 0) + 1
    migrations.each do |migration|
      display_migration migration, size: max_size
    end
  end

  def display_migration(migration, options = {})
    size = options[:size] || migration.name.size
    puts "- #{migration.name.ljust(size)} #{migration.version}"
  end

  def build_migrator
    require 'cassanity/migrator'

    Cassanity::Migrator.new(get_keyspace, Cassanity::Config.instance.migrations_path)
  end

  def get_keyspace
    config = Cassanity::Config.instance
    Cassanity::Client.new(config.hosts, config.port)[config.keyspace.to_sym]
  end

  desc "Run any pending migrations."
  task :migrate do
    migrator = build_migrator
    if ENV["VERSION"]
      version = ENV["VERSION"].to_i
      direction = ENV.fetch('DIRECTION', :up).to_sym
      migrator.migrate_to(version, direction)
    else
      migrator.migrate
    end
  end

  desc "List pending migrations."
  task :pending do
    migrator = build_migrator
    pending = migrator.pending_migrations
    display_migrations pending
  end

  desc "List all migrations."
  task :migrations do
    migrator = build_migrator
    display_migrations migrator.migrations
  end

  desc "Create the keyspace"
  task :create do
    ks = get_keyspace
    unless ks.exists?
      puts "Creating keyspace #{ks.name}"
      ks.create
    end
  end

  desc "Drop the keyspace"
  task :drop do
    ks = get_keyspace
    if ks.exists?
      puts "Dropping keyspace #{ks.name}"
      ks.drop
    end
  end
end
