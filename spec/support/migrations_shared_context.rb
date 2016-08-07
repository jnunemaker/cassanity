shared_context 'migrations' do
  before do
    stub_const 'Cassanity::Config::CONFIG_FILE', 'spec/support/cassanity.erb.yml'
  end
end
