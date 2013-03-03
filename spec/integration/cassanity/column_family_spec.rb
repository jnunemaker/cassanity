require 'helper'
require 'cassanity/keyspace'

describe Cassanity::ColumnFamily do
  let(:keyspace_name)               { 'cassanity_test' }
  let(:column_family_name)          { :apps }
  let(:counters_column_family_name) { :counters }

  let(:client) { Cassanity::Client.new(CassanityServers) }
  let(:driver) { client.driver }

  let(:keyspace) { client[keyspace_name] }

  let(:arguments) {
    {
      keyspace: keyspace,
      name: column_family_name,
      schema: {
        primary_key: :id,
        columns: {
          id: :timeuuid,
          name: :text,
        },
        with: {
          comment: 'For storing things',
        }
      },
    }
  }

  subject {
    described_class.new(arguments)
  }

  before do
    driver_drop_keyspace(driver, keyspace_name)
    driver_create_keyspace(driver, keyspace_name)
    driver_create_column_family(driver, column_family_name, "id text PRIMARY KEY, name text")
    driver_create_column_family(driver, counters_column_family_name, "id text PRIMARY KEY, views counter")
  end

  after do
    driver_drop_keyspace(driver, keyspace_name)
  end

  it "knows if it exists" do
    subject.exists?.should be_true
    driver_drop_column_family(driver, column_family_name)
    subject.exists?.should be_false
  end

  it "can recreate when not created" do
    driver_drop_column_family(driver, column_family_name)
    driver_column_family?(driver, column_family_name).should be_false
    subject.recreate
    driver_column_family?(driver, column_family_name).should be_true
  end

  it "can recreate when already created" do
    driver_column_family?(driver, column_family_name).should be_true
    subject.recreate
    driver_column_family?(driver, column_family_name).should be_true
  end

  it "can create itself" do
    column_family = described_class.new(arguments.merge(name: 'people'))
    column_family.create

    column_families = driver.schema.column_families
    apps_column_family = column_families.fetch(column_family.name.to_s)
    apps_column_family.comment.should eq('For storing things')

    columns = apps_column_family.columns
    columns.should have_key('id')
    columns.should have_key('name')
    columns['id'].should eq('org.apache.cassandra.db.marshal.TimeUUIDType')
    columns['name'].should eq('org.apache.cassandra.db.marshal.UTF8Type')
  end

  it "can truncate" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '1', 'github')
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '2', 'gist')
    result = driver.execute("SELECT * FROM #{column_family_name}")
    result.rows.should eq(2)

    subject.truncate

    result = driver.execute("SELECT * FROM #{column_family_name}")
    result.rows.should eq(0)
  end

  it "can drop" do
    driver_column_family?(driver, column_family_name).should be_true
    subject.drop
    driver_column_family?(driver, column_family_name).should be_false
  end

  it "can drop when using a different keyspace" do
    driver_column_family?(driver, column_family_name).should be_true
    driver.execute('USE system')
    subject.drop
    driver_column_family?(driver, column_family_name).should be_false
  end

  it "can alter" do
    subject.alter(add: {created_at: :timestamp})

    column_families = driver.schema.column_families
    apps_column_family = column_families.fetch(column_family_name.to_s)
    columns = apps_column_family.columns
    columns.should have_key('created_at')
    columns['created_at'].should eq('org.apache.cassandra.db.marshal.DateType')

    subject.alter(alter: {created_at: :timeuuid})

    column_families = driver.schema.column_families
    apps_column_family = column_families.fetch(column_family_name.to_s)
    columns = apps_column_family.columns
    columns.should have_key('created_at')
    columns['created_at'].should eq('org.apache.cassandra.db.marshal.TimeUUIDType')

    subject.alter(drop: :created_at)

    column_families = driver.schema.column_families
    apps_column_family = column_families.fetch(column_family_name.to_s)
    columns = apps_column_family.columns
    columns.should_not have_key('created_at')

    subject.alter(with: {comment: 'Some new comment'})
    column_families = driver.schema.column_families
    apps_column_family = column_families.fetch(column_family_name.to_s)
    apps_column_family.comment.should eq('Some new comment')
  end

  it "can create and drop indexes" do
    subject.create_index({
      name: :apps_name_index,
      column_name: :name,
    })

    apps = driver.schema.column_families.fetch(column_family_name.to_s)
    apps_meta = apps.column_metadata
    index = apps_meta.detect { |c| c.index_name == 'apps_name_index' }
    index.should_not be_nil

    subject.drop_index({
      name: :apps_name_index,
    })

    apps = driver.schema.column_families.fetch(column_family_name.to_s)
    apps_meta = apps.column_metadata
    index = apps_meta.detect { |c| c.index_name == 'apps_name_index' }
    index.should be_nil
  end

  it "can select data" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '1', 'github')
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '2', 'gist')
    result = subject.select({
      select: :name,
      where: {
        id: '2',
      },
    })
    result.should eq([
      {'name' => 'gist'}
    ])
  end

  context "selecting a range of data" do
    let(:name) { 'rollups_minute' }

    subject {
      described_class.new({
        keyspace: keyspace,
        name: name,
      })
    }

    before do
      driver.execute("CREATE COLUMNFAMILY #{name} (id text, ts int, value counter, PRIMARY KEY(id, ts))")
      @id = 'foo'
      driver.execute("UPDATE #{name} SET value = value + 1 WHERE id = ? AND ts = ?", @id, 1)
      driver.execute("UPDATE #{name} SET value = value + 1 WHERE id = ? AND ts = ?", @id, 2)
      driver.execute("UPDATE #{name} SET value = value + 1 WHERE id = ? AND ts = ?", @id, 3)
      driver.execute("UPDATE #{name} SET value = value + 1 WHERE id = ? AND ts = ?", @id, 4)
    end

    it "works including end" do
      subject.select({
        where: {
          id: @id,
          ts: Range.new(1, 3),
        }
      }).should eq([
        {'id' => 'foo', 'ts' => 1, 'value' => 1},
        {'id' => 'foo', 'ts' => 2, 'value' => 1},
        {'id' => 'foo', 'ts' => 3, 'value' => 1},
      ])
    end

    it "works excluding end" do
      subject.select({
        where: {
          id: @id,
          ts: Range.new(1, 3, true),
        }
      }).should eq([
        {'id' => 'foo', 'ts' => 1, 'value' => 1},
        {'id' => 'foo', 'ts' => 2, 'value' => 1},
      ])
    end
  end

  it "can insert data" do
    subject.insert({
      data: {
        id: '1',
        name: 'GitHub',
      },
    })

    result = driver.execute("SELECT * FROM #{column_family_name}")
    result.rows.should eq(1)
    row = result.fetch_hash
    row['id'].should eq('1')
    row['name'].should eq('GitHub')
  end

  it "can update data" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '1', 'github')
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '2', 'gist')

    subject.update({
      set: {name: 'New Name'},
      where: {id: '1'},
    })

    result = driver.execute("SELECT * FROM #{column_family_name} WHERE id = '1'")
    result.rows.should eq(1)
    row = result.fetch_hash
    row['id'].should eq('1')
    row['name'].should eq('New Name')

    # does not update other rows
    result = driver.execute("SELECT * FROM #{column_family_name} WHERE id = '2'")
    result.rows.should eq(1)
    row = result.fetch_hash
    row['id'].should eq('2')
    row['name'].should eq('gist')
  end

  describe "incrementing a counter column" do
    subject {
      described_class.new({
        keyspace: keyspace,
        name: counters_column_family_name,
      })
    }

    it "works" do
      subject.update({
        set: {views: Cassanity::Increment.new(2)},
        where: {id: '1'},
      })

      result = driver.execute("SELECT * FROM #{counters_column_family_name} WHERE id = '1'")
      result.rows.should eq(1)
      row = result.fetch_hash
      row['id'].should eq('1')
      row['views'].should be(2)
    end
  end

  describe "decrementing a counter column" do
    subject {
      described_class.new({
        keyspace: keyspace,
        name: counters_column_family_name,
      })
    }

    it "works" do
      subject.update({
        set: {views: Cassanity::Decrement.new(2)},
        where: {id: '1'},
      })

      result = driver.execute("SELECT * FROM #{counters_column_family_name} WHERE id = '1'")
      result.rows.should eq(1)
      row = result.fetch_hash
      row['id'].should eq('1')
      row['views'].should be(-2)
    end
  end

  it "can delete data" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '1', 'github')
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)", '2', 'gist')

    result = driver.execute("SELECT * FROM #{column_family_name}")
    result.rows.should eq(2)

    subject.delete({
      where: {id: '1'},
    })

    result = driver.execute("SELECT * FROM #{column_family_name} WHERE id = '1'")
    result.rows.should eq(0)

    # does not delete other rows
    result = driver.execute("SELECT * FROM #{column_family_name} WHERE id = '2'")
    result.rows.should eq(1)
  end

  it "can get columns" do
    columns = subject.columns
    columns.map(&:name).should eq([:name])
    columns.map(&:type).should eq([:text])
  end
end
