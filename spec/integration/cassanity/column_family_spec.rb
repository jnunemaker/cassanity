require 'helper'
require 'cassanity/keyspace'

describe Cassanity::ColumnFamily do
  let(:keyspace_name)               { 'cassanity_test' }
  let(:column_family_name)          { :apps }
  let(:counters_column_family_name) { :counters }

  let(:client) { Cassanity::ClientPool.get_client }
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

  it "can select data asynchronously" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('1', 'github')")
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('2', 'gist')")
    future = subject.select_async({
      select: :name,
      where: {
        id: '2',
      },
    })
    future.wait.should eq([
      {'name' => 'gist'}
    ])
  end

  it "can run several selects asynchronously" do
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('1', 'github')")
    driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('2', 'gist')")
    futures = (0..5).map do |i|
      subject.select_async({
        select: :name,
        where: {
          id: i.to_s,
        },
      })
    end
    expect(Cassanity::Future.wait_all(futures)).to eq [
      [],
      [{'name' => 'github'}],
      [{'name' => 'gist'}],
      [],
      [],
      []
    ]
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

  describe 'data insert' do
    let(:attributes) {
      {
        id: '1',
        name: 'GitHub'
      }
    }

    it "can insert synchronously data" do
      subject.insert data: attributes

      result = driver.execute("SELECT * FROM #{column_family_name}")
      result.to_a.length.should eq(1)
      row = result.first
      row['id'].should eq('1')
      row['name'].should eq('GitHub')
    end

    it "can asynchronously insert data" do
      driver.should_receive(:execute_async).once.and_call_original

      expect do
        future = subject.insert_async data: attributes
        future.wait
      end.to change { column_family_count driver, column_family_name }.from(0).to 1

      result = driver.execute("SELECT * FROM #{column_family_name}")
      result.to_a.length.should eq(1)
      row = result.first
      row['id'].should eq('1')
      row['name'].should eq('GitHub')
    end
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

  describe 'prepared statements' do
    describe 'preparing select' do
      it 'successfully prepares the statement' do
        subject.prepare_select({
          where: {
            id: Cassanity::SingleFieldPlaceholder.new
          }
        }).should be_a Cassanity::PreparedStatement
      end

      it 'successfully uses prepared statements' do
        driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('1', 'github')")
        driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('2', 'gist')")

        stmt = subject.prepare_select({
          select: :name,
          where: {
            id: Cassanity::SingleFieldPlaceholder.new
          }
        })

        expect(stmt.execute id: '2').to eq [{'name' => 'gist'}]
      end

      it 'works with arrays' do
        10.times do |i|
          driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('#{i}', 'name#{i}')")
        end

        stmt = subject.prepare_select({
          select: :name,
          where: {
            id: Cassanity::ArrayPlaceholder.new(3)
          }
        })

        expect(stmt.execute id: %w(2 5 8)).to eq [{'name' => 'name2'}, {'name' => 'name5'}, {'name' => 'name8'}]
      end

      describe 'nummeric based clauses' do
        let(:events_cf_name) { 'events' }
        let(:start_time) { Time.now.round }
        let(:column_family) { keyspace.column_family events_cf_name }

        before do
          driver_create_column_family(driver, events_cf_name, "app_id text, event text, time timestamp, PRIMARY KEY(app_id, time)")

          10.times do |i|
            driver.execute("INSERT INTO #{events_cf_name} (app_id, event, time) VALUES ('1', 'event#{i}', '#{(start_time + i).to_s}')")
          end
        end

        describe 'ranges' do
          it 'works with (and defaults to) exclusive ranges' do
            stmt = column_family.prepare_select({
              select: :event,
              where: {
                app_id: Cassanity::SingleFieldPlaceholder.new,
                time: Cassanity::RangePlaceholder.new
              }
            })

            expect(stmt.execute app_id: '1', time: (start_time..(start_time+2))).to eq [{'event' => 'event0'}, {'event' => 'event1'}]
          end

          it 'works with inclusive ranges' do
            stmt = column_family.prepare_select({
              select: :event,
              where: {
                app_id: Cassanity::SingleFieldPlaceholder.new,
                time: Cassanity::RangePlaceholder.new(false)
              }
            })

            expect(stmt.execute app_id: '1', time: (start_time..(start_time+2))).to eq [
              {'event' => 'event0'}, {'event' => 'event1'}, {'event' => 'event2'}
            ]
          end
        end

        it 'works with non equals operators' do
          stmt = column_family.prepare_select({
            select: :event,
            where: {
              app_id: Cassanity::SingleFieldPlaceholder.new,
              time: Cassanity::SingleFieldPlaceholder.new('>')
            }
          })

          expect(stmt.execute app_id: '1', time: start_time+7).to eq [{'event' => 'event8'}, {'event' => 'event9'}]
        end
      end

      it 'successfully uses prepared statements asynchronously if required' do
        driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('1', 'github')")
        driver.execute("INSERT INTO #{column_family_name} (id, name) VALUES ('2', 'gist')")

        stmt = subject.prepare_select({
          select: :name,
          where: {
            id: Cassanity::SingleFieldPlaceholder.new
          }
        })

        futures = [1, 2].map do |i|
          stmt.execute_async id: i.to_s
        end

        expect(Cassanity::Future.wait_all(futures).flatten).to eq [{'name' => 'github'}, {'name' => 'gist'}]
      end
    end


    describe 'preparing insert' do
      it 'successfully prepares the statement' do
        subject.prepare_insert({
          fields: [:id, :name]
        }).should be_a Cassanity::PreparedStatement
      end

      it "doesn't executes the statement" do
        expect { subject.prepare_insert({
          fields: [:id, :name]
        }) }.to_not change { driver.execute("SELECT * FROM #{column_family_name}").to_a.length }.from 0
      end

      it 'successfully uses prepared statements' do
        stmt = subject.prepare_insert({
          fields: [:id, :name]
        })

        expect {
          stmt.execute id: '1', name: 'GitHub'
          stmt.execute id: '2', name: 'GitHub'
          stmt.execute id: '3', name: 'GitHub'
        }.to change { driver.execute("SELECT * FROM #{column_family_name}").to_a.length }.from(0).to 3
      end

      it 'successfully uses prepared statements asynchronously if required' do
        stmt = subject.prepare_insert({
          fields: [:id, :name]
        })

        expect {
          futures = (1..3).map do |i|
            stmt.execute_async id: i.to_s, name: 'GitHub'
          end

          Cassanity::Future.wait_all futures
        }.to change { driver.execute("SELECT * FROM #{column_family_name}").to_a.length }.from(0).to 3
      end
    end
  end
end
