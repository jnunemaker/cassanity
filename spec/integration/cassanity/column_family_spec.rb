require 'helper'
require 'cassanity/keyspace'

describe Cassanity::ColumnFamily do
  let(:keyspace_name)               { 'cassanity_test' }
  let(:column_family_name)          { :apps }
  let(:counters_column_family_name) { :counters }

  let(:client) { Cassanity::Client.new(CassanityHost, CassanityPort) }
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

    families = driver.execute("SELECT * from system.schema_columnfamilies WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='people' ALLOW FILTERING")
    people_column_family = families.first
    people_column_family['comment'].should eq('For storing things')

    columns = driver.execute("SELECT * from system.schema_columns WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='people' ALLOW FILTERING")
    id = columns.detect { |c| c['column_name'] == 'id' }
    id.should_not be_nil
    id['validator'].should eq('org.apache.cassandra.db.marshal.TimeUUIDType')

    name = columns.detect { |c| c['column_name'] == 'name' }
    name.should_not be_nil
    name['validator'].should eq('org.apache.cassandra.db.marshal.UTF8Type')
  end

  it "can truncate" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('1', 'github')")
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('2', 'gist')")
    result = driver.execute("SELECT * FROM #{column_family_name}")
    result.to_a.length.should eq(2)

    subject.truncate

    result = driver.execute("SELECT * FROM #{column_family_name}")
    result.to_a.length.should eq(0)
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
    subject.alter(add: {some_text: :text})

    columns = driver.execute("SELECT * from system.schema_columns WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='apps' ALLOW FILTERING")
    some_text = columns.detect { |c| c['column_name'] == 'some_text' }
    some_text.should_not be_nil
    some_text['validator'].should eq('org.apache.cassandra.db.marshal.UTF8Type')

    subject.alter(alter: {some_text: :blob})

    columns = driver.execute("SELECT * from system.schema_columns WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='apps' ALLOW FILTERING")
    some_text = columns.detect { |c| c['column_name'] == 'some_text' }
    some_text.should_not be_nil
    some_text['validator'].should eq('org.apache.cassandra.db.marshal.BytesType')

    subject.alter(drop: :some_text)

    columns = driver.execute("SELECT * from system.schema_columns WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='apps' ALLOW FILTERING")
    some_text = columns.detect { |c| c['column_name'] == 'some_text' }
    some_text.should be_nil

    subject.alter(with: {comment: 'Some new comment'})
    families = driver.execute("SELECT * from system.schema_columnfamilies WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='apps' ALLOW FILTERING")
    apps_column_family = families.first
    apps_column_family['comment'].should eq('Some new comment')
  end

  it "can create and drop indexes" do
    subject.create_index({
      name: :apps_name_index,
      column_name: :name,
    })

    columns = driver.execute("SELECT * from system.schema_columns WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='apps' ALLOW FILTERING")
    index = columns.detect { |c| c['index_name'] == 'apps_name_index' }
    index.should_not be_nil

    subject.drop_index({
      name: :apps_name_index,
    })

    columns = driver.execute("SELECT * from system.schema_columns WHERE keyspace_name='#{driver.keyspace}' AND columnfamily_name='apps' ALLOW FILTERING")
    index = columns.detect { |c| c['index_name'] == 'apps_name_index' }
    index.should be_nil
  end

  it "can select data" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('1', 'github')")
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('2', 'gist')")
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
      driver.execute("UPDATE #{name} SET value = value + 1 WHERE id = '#@id' AND ts = 1")
      driver.execute("UPDATE #{name} SET value = value + 1 WHERE id = '#@id' AND ts = 2")
      driver.execute("UPDATE #{name} SET value = value + 1 WHERE id = '#@id' AND ts = 3")
      driver.execute("UPDATE #{name} SET value = value + 1 WHERE id = '#@id' AND ts = 4")
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
    result.to_a.length.should eq(1)
    row = result.first
    row['id'].should eq('1')
    row['name'].should eq('GitHub')
  end

  it "can update data" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('1', 'github')")
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('2', 'gist')")

    subject.update({
      set: {name: 'New Name'},
      where: {id: '1'},
    })

    result = driver.execute("SELECT * FROM #{column_family_name} WHERE id = '1'")
    result.to_a.length.should eq(1)
    row = result.first
    row['id'].should eq('1')
    row['name'].should eq('New Name')

    # does not update other rows
    result = driver.execute("SELECT * FROM #{column_family_name} WHERE id = '2'")
    result.to_a.length.should eq(1)
    row = result.first
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
      result.to_a.length.should eq(1)
      row = result.first
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
      result.to_a.length.should eq(1)
      row = result.first
      row['id'].should eq('1')
      row['views'].should be(-2)
    end
  end

  it "can delete data" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('1', 'github')")
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('2', 'gist')")

    result = driver.execute("SELECT * FROM #{column_family_name}")
    result.to_a.length.should eq(2)

    subject.delete({
      where: {id: '1'},
    })

    result = driver.execute("SELECT * FROM #{column_family_name} WHERE id = '1'")
    result.to_a.length.should eq(0)

    # does not delete other rows
    result = driver.execute("SELECT * FROM #{column_family_name} WHERE id = '2'")
    result.to_a.length.should eq(1)
  end

  it "can get columns" do
    columns = subject.columns
    columns.map(&:name).should eq([:id, :name])
    columns.map(&:type).should eq([:text, :text])
  end
end
