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
          name: 'tracks',
          schema: schema,
        }
      }

      [:name, :schema].each do |key|
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
          name: column_family_name,
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
          name: column_family_name,
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
          name: column_family_name,
          schema: schema,
        }).should eq(expected)
      end
    end

    context "when using with options" do
      it "returns array of arguments" do
        schema = Cassanity::Schema.new({
          primary_key: :id,
          columns: {
            id: :text,
            name: :text,
          },
          with: {
            comment: "YOU CAN'T HANDLE THE TRUTH",
            read_repair_chance: 1.0,
          }
        })
        cql = "CREATE COLUMNFAMILY #{column_family_name} (id text, name text, PRIMARY KEY (id)) WITH comment = ? AND read_repair_chance = ?"
        expected = [cql, "YOU CAN'T HANDLE THE TRUTH", 1.0]
        subject.call({
          name: column_family_name,
          schema: schema,
        }).should eq(expected)
      end
    end

    context "when using with options that have sub options" do
      it "returns array of arguments" do
        schema = Cassanity::Schema.new({
          primary_key: :id,
          columns: {
            id: :text,
            name: :text,
          },
          with: {
            comment: "YOU CAN'T HANDLE THE TRUTH",
            compaction_strategy_options: {
              min_compaction_threshold: 6,
              max_compaction_threshold: 40,
            },
          }
        })
        cql = "CREATE COLUMNFAMILY #{column_family_name} (id text, name text, PRIMARY KEY (id)) WITH comment = ? AND compaction_strategy_options:min_compaction_threshold = ? AND compaction_strategy_options:max_compaction_threshold = ?"
        expected = [cql, "YOU CAN'T HANDLE THE TRUTH", 6, 40]
        subject.call({
          name: column_family_name,
          schema: schema,
        }).should eq(expected)
      end
    end
  end
end
