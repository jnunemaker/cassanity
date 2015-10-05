namespace :cassanity do

  class CassanityRakeHelper
    # This class is merely a container of data and methods for this rake tasks.
    # It is basically to avoid cluttering the top level ruby object with this
    # convenience methods/attributes. This is because Rake runs in the top level
    # object as it's context.
    include Singleton

    def self.migrator
      instance.migrator
    end

    def self.keyspace
      instance.keyspace
    end

    def self.display_migrations(migrations)
      left_padding = (migrations.map(&:name).map(&:size).max || 0) + 1
      migrations.each do |migration|
        display_migration migration, left_padding
      end
    end

    def self.display_migration(migration, left_padding)
      puts "- #{migration.name.ljust(left_padding)} #{migration.version}"
    end

    def migrator
      @migrator ||= begin
        require 'cassanity/migrator'

        Cassanity::Migrator.new(keyspace, Cassanity::Config.instance.migrations_path)
      end
    end

    def keyspace
      @keyspace ||= begin
        config = Cassanity::Config.instance
        Cassanity::Client.new(config.hosts, config.port)[config.keyspace.to_sym]
      end
    end
  end

  desc "Run any pending migrations."
  task :migrate => [:create] do
    if ENV["VERSION"]
      version = ENV["VERSION"].to_i
      direction = ENV.fetch('DIRECTION', :up).to_sym
      CassanityRakeHelper.migrator.migrate_to(version, direction)
    else
      CassanityRakeHelper.migrator.migrate
    end
  end

  desc "List pending migrations."
  task :pending do
    pending = CassanityRakeHelper.migrator.pending_migrations
    CassanityRakeHelper.display_migrations pending
  end

  desc "List all migrations."
  task :migrations do
    migrations = CassanityRakeHelper.migrator.migrations
    CassanityRakeHelper.display_migrations migrations
  end

  desc "Create the keyspace"
  task :create do
    unless CassanityRakeHelper.keyspace.exists?
      puts "Creating keyspace #{CassanityRakeHelper.keyspace.name}"
      CassanityRakeHelper.keyspace.create
    end
  end

  desc "Drop the keyspace"
  task :drop do
    if CassanityRakeHelper.keyspace.exists?
      puts "Dropping keyspace #{CassanityRakeHelper.keyspace.name}"
      CassanityRakeHelper.keyspace.drop
    end
  end
end
