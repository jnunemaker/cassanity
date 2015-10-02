shared_context 'migrations' do
  let(:migrator) { double Cassanity::Migrator }

  before do
    stub_const 'Cassanity::Config::CONFIG_FILE', 'spec/support/cassanity.erb.yml'
    allow(Cassanity::Migrator).to receive(:new).and_return migrator
  end
end
