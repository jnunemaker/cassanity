
require 'ostruct'
require 'yaml'
require 'singleton'
require 'erb'

module Cassanity
  class Config < OpenStruct
    include Singleton

    CONFIG_FILE = 'config/cassanity.erb.yml'

    def initialize
      super YAML::load(ERB.new(File.read(CONFIG_FILE)).result)[environment]
    end

    def environment
      ENV['CASSANITY_ENV'] || 'development'
    end

  end
end
