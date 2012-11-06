require 'helper'
require 'cassanity/argument_generators/column_family_alter'

describe Cassanity::ArgumentGenerators::ColumnFamilyAlter do
  describe "#call" do
    it "returns array of arguments" do
      cql = "ALTER COLUMNFAMILY apps"
      expected = [cql]
      subject.call({
        name: :apps,
      }).should eq(expected)
    end

    context "with :keyspace_name" do
      it "returns array of arguments including keyspace name" do
        cql = "ALTER COLUMNFAMILY foo.apps"
        expected = [cql]
        subject.call({
          name: :apps,
          keyspace_name: 'foo',
        }).should eq(expected)
      end
    end

    context "altering a column type" do
      it "returns array of arguments" do
        cql = "ALTER COLUMNFAMILY apps ALTER created_at TYPE timestamp"
        expected = [cql]
        subject.call({
          name: :apps,
          alter: {
            created_at: :timestamp,
          },
        }).should eq(expected)
      end
    end

    context "adding a column" do
      it "returns array of arguments" do
        cql = "ALTER COLUMNFAMILY apps ADD created_at timestamp"
        expected = [cql]
        subject.call({
          name: :apps,
          add: {
            created_at: :timestamp,
          },
        }).should eq(expected)
      end
    end

    context "dropping a column" do
      it "returns array of arguments" do
        cql = "ALTER COLUMNFAMILY apps DROP created_at"
        expected = [cql]
        subject.call({
          name: :apps,
          drop: :created_at,
        }).should eq(expected)
      end
    end

    context "altering column family WITH options" do
      let(:with_clause) {
        lambda { |args| [" WITH comment = ?", 'Testing']}
      }

      subject {
        described_class.new({
          with_clause: with_clause,
        })
      }

      it "returns array of arguments with help from the with_clause" do
        cql = "ALTER COLUMNFAMILY apps WITH comment = ?"
        expected = [cql, 'Testing']
        subject.call({
          name: :apps,
          with: {
            comment: 'Testing',
          }
        }).should eq(expected)
      end
    end
  end
end
