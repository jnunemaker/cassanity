require 'helper'
require 'cassanity/migrator'

describe 'cassanity:migrate' do
  include_context 'rake'

  let(:migrator) { double Cassanity::Migrator }

  before do
    stub_const 'Cassanity::Config::CONFIG_FILE', 'spec/support/cassanity.erb.yml'
    allow(Cassanity::Migrator).to receive(:new).and_return migrator
  end

  it 'migrates' do
    expect(migrator).to receive :migrate
    subject.invoke
  end

  context 'specifying target version' do

    let(:target_version) { 139 }

    before do
      ENV.delete 'DIRECTION'
      ENV['VERSION'] = target_version.to_s
    end

    it 'migrates up to a specific version' do
      expect(migrator).to receive(:migrate_to).with target_version, :up
      subject.invoke
    end

    it 'migrates down to a specific version' do
      ENV['DIRECTION'] = 'down'
      expect(migrator).to receive(:migrate_to).with target_version, :down
      subject.invoke
    end
  end
end
