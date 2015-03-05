
require 'ostruct'
require 'yaml'
require 'singleton'

module Cassanity
  class Config < OpenStruct
    include Singleton

    CONFIG_FILE = 'config/cassanity.yml'

    def initialize
      super YAML::load_file(CONFIG_FILE)[environment]
    end

    def environment
      ENV['CASSANITY_ENV'] || 'development'
    end

  end
end
