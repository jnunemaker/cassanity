require 'helper'
require 'cassanity/migrator'

describe 'cassanity:migrate' do
  include_context 'rake'
  include_context 'migrations'

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

describe 'cassanity:pending' do
  include_context 'rake'
  include_context 'migrations'

  let(:main) { TOPLEVEL_BINDING.eval('self') }

  it 'lists pending migrations' do
    migration_name = 'Migration1'
    migration = double Cassanity::MigrationProxy, name: migration_name
    migration_name2 = 'Migration_2'
    migration2 = double Cassanity::MigrationProxy, name: migration_name2
    allow(migrator).to receive(:pending_migrations).and_return [migration, migration2]
    expect(main).to receive(:display_migration).with(migration, migration_name2.size + 1)
    expect(main).to receive(:display_migration).with(migration2, migration_name2.size + 1)
    subject.invoke
  end

  it 'lists nothing if no pending migrations' do
    allow(migrator).to receive(:pending_migrations).and_return []
    expect(main).not_to receive :display_migration
    subject.invoke
  end
end
