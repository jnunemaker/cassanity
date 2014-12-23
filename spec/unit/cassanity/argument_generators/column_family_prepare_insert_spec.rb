require 'helper'
require 'cassanity/argument_generators/column_family_prepare_insert'

describe Cassanity::ArgumentGenerators::ColumnFamilyPrepareInsert do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    [:column_family_name, :fields].each do |key|
      it "raises error if missing :#{key} key" do
        required_arguments = {
          column_family_name: column_family_name,
          fields: [:id, :name]
        }

        args = required_arguments.reject { |k, v| k == key }
        expect { subject.call(args) }.to raise_error(KeyError)
      end
    end

    it "returns array of arguments" do
      cql = "INSERT INTO #{column_family_name} (id, name) VALUES (?, ?)"
      expected = [cql, []]
      subject.call({
          column_family_name: column_family_name,
          fields: [:id, :name]
      }).should eq(expected)
    end

    context "with :keyspace_name" do
      it "returns array of arguments" do
        cql = "INSERT INTO foo.#{column_family_name} (id, name) VALUES (?, ?)"
        expected = [cql, []]
        subject.call({
          keyspace_name: :foo,
          column_family_name: column_family_name,
          fields: [:id, :name]
        }).should eq(expected)
      end
    end

    context "with :using key" do
      it "returns array of arguments including using in cql string" do
        millis = (Time.mktime(2012, 11, 1, 14, 9, 9).to_f * 1000).to_i
        cql = "INSERT INTO #{column_family_name} (id, name) VALUES (?, ?) USING TTL 86400 AND TIMESTAMP #{millis} AND CONSISTENCY quorum"
        expected = [cql, []]
        subject.call({
          column_family_name: column_family_name,
          fields: [:id, :name],
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
