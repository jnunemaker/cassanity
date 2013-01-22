require 'helper'
require 'cassanity/argument_generators/column_family_create'

describe Cassanity::ArgumentGenerators::ColumnFamilyCreate do
  let(:column_family_name) { 'tracks' }

  let(:schema) {
    Cassanity::Schema.new({
      primary_key: :id,
      columns: {
        id: :text,
        name: :text
      },
    })
  }

  describe "#call" do
    context "when missing required argument key" do
      let(:required_arguments) {
        {
          column_family_name: column_family_name,
          schema: schema,
        }
      }

      [:column_family_name, :schema].each do |key|
        it "raises error if missing :#{key} key" do
          args = required_arguments.reject { |k, v| k == key }
          expect { subject.call(args) }.to raise_error(KeyError)
        end
      end
    end

    context "when using single primary key" do
      it "returns array of arguments" do
        cql = "CREATE COLUMNFAMILY #{column_family_name} (id text, name text, PRIMARY KEY (id))"
        expected = [cql]
        subject.call({
          column_family_name: column_family_name,
          schema: schema,
        }).should eq(expected)
      end
    end

    context "when including :keyspace_name" do
      it "returns array of arguments" do
        cql = "CREATE COLUMNFAMILY foo.#{column_family_name} (id text, name text, PRIMARY KEY (id))"
        expected = [cql]
        subject.call({
          keyspace_name: :foo,
          column_family_name: column_family_name,
          schema: schema,
        }).should eq(expected)
      end
    end

    context "when using composite primary key" do
      it "returns array of arguments" do
        schema = Cassanity::Schema.new({
          primary_key: [:segment, :track_id],
          columns: {
            segment: :text,
            track_id: :timeuuid,
            page: :text,
          },
        })
        cql = "CREATE COLUMNFAMILY #{column_family_name} (segment text, track_id timeuuid, page text, PRIMARY KEY (segment, track_id))"
        expected = [cql]
        subject.call({
          column_family_name: column_family_name,
          schema: schema,
        }).should eq(expected)
      end
    end

    context "when using WITH options" do
      let(:with_clause) {
        lambda { |args| [" WITH comment = ?", 'Testing']}
      }

      subject {
        described_class.new({
          with_clause: with_clause,
        })
      }

      it "returns array of arguments with help from the with_clause" do
        schema = Cassanity::Schema.new({
          primary_key: :id,
          columns: {
            id: :text,
            name: :text,
          },
          with: {
            comment: "Testing",
          }
        })
        cql = "CREATE COLUMNFAMILY apps (id text, name text, PRIMARY KEY (id)) WITH comment = ?"
        expected = [cql, 'Testing']
        subject.call({
          column_family_name: :apps,
          schema: schema,
        }).should eq(expected)
      end
    end
  end
end
