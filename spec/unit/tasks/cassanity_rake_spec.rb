require 'helper'
require 'cassanity/migrator'
require 'cassanity/migration'

describe 'cassanity:migrate' do
  include_context 'rake'
  include_context 'migrations'

  let(:migrator) { CassanityRakeHelper.migrator }
  let(:keyspace) { CassanityRakeHelper.keyspace }

  before do
    keyspace.drop if keyspace.exists?
    keyspace.create
  end

  it 'migrates' do
    expect do
      subject.invoke
    end.to change { migrator.pending_migrations.count }.from(2).to 0
  end

  context 'specifying target version' do

    before do
      ENV.delete 'DIRECTION'
      ENV.delete 'VERSION'
    end

    it 'migrates up to a specific version' do
      ENV['VERSION'] = '1'
      expect do
        subject.invoke
      end.to change { migrator.pending_migrations.map(&:version) }.from([1, 2]).to [2]
    end

    it 'migrates down to a specific version' do
      migrator.migrate
      ENV['VERSION'] = '1'
      ENV['DIRECTION'] = 'down'
      expect do
        subject.invoke
      end.to change { migrator.pending_migrations.map(&:version) }.from([]).to [2]
    end
  end
end

describe 'cassanity:pending' do
  include_context 'rake'
  include_context 'migrations'

  let(:migrator) { CassanityRakeHelper.migrator }
  let(:keyspace) { CassanityRakeHelper.keyspace }

  before do
    keyspace.drop if keyspace.exists?
    keyspace.create
  end

  it 'lists pending migrations' do
    expect(migrator.migrations.count).to eq 2
    migrator.migrations.each do |m|
      expect(CassanityRakeHelper).to receive(:display_migration).with(m, 9)
    end
    subject.invoke
  end

  it 'lists nothing if no pending migrations' do
    migrator.migrate
    expect(CassanityRakeHelper).not_to receive :display_migration
    subject.invoke
  end
end

describe 'cassanity:migrations' do
  include_context 'rake'
  include_context 'migrations'

  let(:migrator) { CassanityRakeHelper.migrator }
  let(:keyspace) { CassanityRakeHelper.keyspace }

  before do
    keyspace.drop if keyspace.exists?
    keyspace.create
  end

  it 'lists all migrations' do
    expect(migrator.migrations.count).to eq 2
    migrator.migrations.each do |m|
      expect(CassanityRakeHelper).to receive(:display_migration).with(m, 9)
    end
    subject.invoke
  end

  it 'lists nothing if no migrations' do
    allow(migrator).to receive(:migrations).and_return []
    expect(CassanityRakeHelper).not_to receive :display_migration
    subject.invoke
  end
end

describe 'cassanity:create' do
  include_context 'rake'
  include_context 'migrations'

  let(:keyspace) { CassanityRakeHelper.keyspace }

  it 'creates if not exists' do
    keyspace.drop if keyspace.exists?
    expect {
      subject.invoke
    }.to change(keyspace, :exists?).from(false).to true
  end

  it "doesn't create if already exists" do
    keyspace.create unless keyspace.exists?
    expect(keyspace).not_to receive :create
    subject.invoke
  end
end

describe 'cassanity:drop' do
  include_context 'rake'
  include_context 'migrations'

  let(:keyspace) { CassanityRakeHelper.keyspace }

  it 'drops if exists' do
    keyspace.create unless keyspace.exists?
    expect {
      subject.invoke
    }.to change(keyspace, :exists?).from(true).to false
  end

  it "doesn't drop if already doesn't exist" do
    keyspace.drop if keyspace.exists?
    expect(keyspace).not_to receive :drop
    subject.invoke
  end
end
