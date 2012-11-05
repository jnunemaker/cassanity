require 'helper'
require 'cassanity/argument_generators/column_family_insert'

describe Cassanity::ArgumentGenerators::ColumnFamilyInsert do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    [:name, :data].each do |key|
      it "raises error if missing :#{key} key" do
        arguments = {
          name: column_family_name,
          data: {
            id: '1',
            name: 'GitHub',
          }
        }

        expect {
          subject.call(arguments.except(key))
        }.to raise_error
      end
    end

    it "returns array of arguments" do
      cql = "INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)"
      expected = [cql, '1', 'GitHub']
      subject.call({
        name: column_family_name,
        data: {
          id: '1',
          name: 'GitHub',
        }
      }).should eq(expected)
    end

    context "with :using key" do
      it "returns array of arguments including using in cql string" do
        millis = (Time.mktime(2012, 11, 1, 14, 9, 9).to_f * 1000).to_i
        cql = "INSERT INTO #{column_family_name} (id, name) VALUES (?, ?) USING TTL 86400 AND TIMESTAMP #{millis} AND CONSISTENCY quorum"
        expected = [cql, '1', 'GitHub']
        subject.call({
          name: column_family_name,
          data: {
            id: '1',
            name: 'GitHub',
          },
          using: {
            ttl: 86400,
            timestamp: millis,
            consistency: 'quorum',
          }
        }).should eq(expected)
      end
    end
  end
end
