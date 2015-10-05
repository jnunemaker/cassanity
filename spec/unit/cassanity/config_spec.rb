require 'helper'
require 'cassanity/config'

describe Cassanity::Config do

  before do
    stub_const 'Cassanity::Config::CONFIG_FILE', 'spec/support/cassanity.erb.yml'
  end

  after do
    ENV['CASSANITY_ENV'] = 'test'
  end

  let(:config) { Class.new(Cassanity::Config).instance }

  it 'successfully reads hosts config' do
    config.hosts.should eq ['127.0.0.1']
  end

  it 'successfully reads port config' do
    ENV.delete 'CASSANDRA_PORT'
    config.port.should eq 9042
  end

  it 'successfully parses erb port config' do
    ENV['CASSANDRA_PORT'] = '1111'
    config.port.should eq 1111
  end

  { development: '_dev', test: '_test', production: '' }.each do |env, suffix|
    it "successfully reads #{env} keyspace config" do
      ENV['CASSANITY_ENV'] = env.to_s
      config.keyspace.should eq "cassanity#{suffix}"
    end
  end

  it 'successfully reads migrations path' do
    config.migrations_path.should eq 'spec/migrations'
  end

end
