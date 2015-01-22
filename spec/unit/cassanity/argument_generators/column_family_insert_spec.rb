require 'helper'
require 'cassanity/argument_generators/column_family_insert'

describe Cassanity::ArgumentGenerators::ColumnFamilyInsert do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    [:column_family_name, :data].each do |key|
      it "raises error if missing :#{key} key" do
        required_arguments = {
          column_family_name: column_family_name,
          data: {
            id: '1',
            name: 'GitHub',
          }
        }

        args = required_arguments.reject { |k, v| k == key }
        expect { subject.call(args) }.to raise_error(KeyError)
      end
    end

    it "returns array of arguments" do
      cql = "INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)"
      expected = [cql, '1', 'GitHub']
      subject.call({
        column_family_name: column_family_name,
        data: {
          id: '1',
          name: 'GitHub',
        }
      }).should eq(expected)
    end

    context "with :keyspace_name" do
      it "returns array of arguments" do
        cql = "INSERT INTO foo.#{column_family_name} (id, name) VALUES (?, ?)"
        expected = [cql, '1', 'GitHub']
        subject.call({
          keyspace_name: :foo,
          column_family_name: column_family_name,
          data: {
            id: '1',
            name: 'GitHub',
          }
        }).should eq(expected)
      end
    end

    context "with :using key" do
      it "returns array of arguments including using in cql string" do
        millis = (Time.mktime(2012, 11, 1, 14, 9, 9).to_f * 1000).to_i
        cql = "INSERT INTO #{column_family_name} (id, name) VALUES (?, ?) USING TTL 86400 AND TIMESTAMP #{millis} AND CONSISTENCY quorum"
        expected = [cql, '1', 'GitHub']
        subject.call({
          column_family_name: column_family_name,
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

    context "with :upsert key" do
      it "returns array of arguments with upsert disabled" do
        cql = "INSERT INTO #{column_family_name} (id, name) VALUES (?, ?) IF NOT EXISTS"
        expected = [cql, '1', 'GitHub']
        subject.call({
          column_family_name: column_family_name,
          data: {
            id: '1',
            name: 'GitHub',
          },
          upsert: false
        }).should eq(expected)
      end
    end
  end
end
