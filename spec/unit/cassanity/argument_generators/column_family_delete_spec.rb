require 'helper'
require 'cassanity/argument_generators/column_family_delete'

describe Cassanity::ArgumentGenerators::ColumnFamilyDelete do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    it "returns array of arguments" do
      cql = "DELETE FROM #{column_family_name} WHERE \"id\" = ?"
      expected = [cql, '1']
      subject.call({
        column_family_name: column_family_name,
        where: {
          id: '1',
        }
      }).should eq(expected)
    end

    context "with :keyspace_name" do
      it "returns array of arguments" do
        cql = "DELETE FROM foo.#{column_family_name} WHERE \"id\" = ?"
        expected = [cql, '1']
        subject.call({
          keyspace_name: :foo,
          column_family_name: column_family_name,
          where: {
            id: '1',
          }
        }).should eq(expected)
      end
    end

    context "with single column" do
      it "returns array of arguments only deleting specific column" do
        cql = "DELETE foo FROM #{column_family_name} WHERE \"id\" = ?"
        expected = [cql, '1']
        subject.call({
          column_family_name: column_family_name,
          columns: :foo,
          where: {
            id: '1',
          }
        }).should eq(expected)
      end
    end

    context "with specific columns" do
      it "returns array of arguments only deleting specific columns" do
        cql = "DELETE foo, bar FROM #{column_family_name} WHERE \"id\" = ?"
        expected = [cql, '1']
        subject.call({
          column_family_name: column_family_name,
          columns: [:foo, :bar],
          where: {
            id: '1',
          }
        }).should eq(expected)
      end
    end

    context "with one collection item" do
      it "returns array of arguments only deleting the collection item" do
        cql = "DELETE foo[0] FROM #{column_family_name} WHERE \"id\" = ?"
        expected = [cql, '1']
        subject.call({
          column_family_name: column_family_name,
          columns: Hash[:foo, 0],
          where: {
            id: '1',
          }
        }).should eq(expected)
      end
    end

    context "with multiple collection items" do
      it "returns array of arguments only deleting the collection items" do
        cql = "DELETE foo[0], foo[3], foo[4], foo[7] FROM #{column_family_name} WHERE \"id\" = ?"
        expected = [cql, '1']
        subject.call({
          column_family_name: column_family_name,
          columns: Hash[:foo, [0,3,4,7]],
          where: {
            id: '1',
          }
        }).should eq(expected)
      end
    end

    context "with standard columns and collection items" do
      it "returns array of arguments only deleting given columns" do
        cql = "DELETE bar, foo[0] FROM #{column_family_name} WHERE \"id\" = ?"
        expected = [cql, '1']
        subject.call({
          column_family_name: column_family_name,
          columns: [:bar, Hash[:foo, [0]]],
          where: {
            id: '1',
          }
        }).should eq(expected)
      end
    end

    context "with :where key" do
      subject {
        described_class.new({
          where_clause: lambda { |args|
            [" WHERE \"id\" = ?", args.fetch(:where).fetch(:id)]
          }
        })
      }

      it "uses where clause to get additional cql and bound variables" do
        cql = "DELETE FROM #{column_family_name} WHERE \"id\" = ?"
        expected = [cql, '4']
        subject.call({
          column_family_name: column_family_name,
          where: {
            id: '4',
          }
        }).should eq(expected)
      end
    end

    context "with :using key" do
      subject {
        described_class.new({
          using_clause: lambda { |args|
            [" USING TTL = #{args.fetch(:using).fetch(:ttl)}"]
          }
        })
      }

      it "uses using clause to get additional cql and bound variables" do
        cql = "DELETE FROM #{column_family_name} USING TTL = 500 WHERE \"id\" = ?"
        expected = [cql, '4']
        subject.call({
          column_family_name: column_family_name,
          using: {
            ttl: 500,
          },
          where: {
            id: '4',
          }
        }).should eq(expected)
      end
    end
  end
end
