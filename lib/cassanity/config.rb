
require 'ostruct'
require 'yaml'
require 'singleton'
require 'erb'

module Cassanity
  class Config
    include Singleton

    CONFIG_FILE = 'config/cassanity.erb.yml'

    def initialize
      @table = YAML::load(ERB.new(File.read(CONFIG_FILE)).result)[environment]
    end

    def environment
      ENV['CASSANITY_ENV'] || 'development'
    end

    def hosts
      @table[:hosts]
    end

    def port
      @table[:port]
    end

    def migrations_path
      @table[:migrations_path]
    end

    def keyspace
      @table[:keyspace]
    end
  end
end
