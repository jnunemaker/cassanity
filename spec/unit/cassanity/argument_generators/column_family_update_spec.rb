require 'helper'
require 'cassanity/argument_generators/column_family_update'

describe Cassanity::ArgumentGenerators::ColumnFamilyUpdate do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    it "returns array of arguments" do
      cql = "UPDATE #{column_family_name} SET name = ? WHERE id = ?"
      expected = [cql, 'New Name', '1']
      subject.call({
        name: column_family_name,
        set: {
          name: 'New Name',
        },
        where: {
          id: '1',
        }
      }).should eq(expected)
    end

    context "with :where key" do
      subject {
        described_class.new({
          where_clause: lambda { |args|
            [" WHERE id = ?", args.fetch(:where).fetch(:id)]
          }
        })
      }

      it "uses where clause to get additional cql and bound variables" do
        cql = "UPDATE #{column_family_name} SET name = ? WHERE id = ?"
        expected = [cql, 'New Name', '4']
        subject.call({
          name: column_family_name,
          set: {
            name: 'New Name',
          },
          where: {
            id: '4',
          }
        }).should eq(expected)
      end
    end

    context "with :set key" do
      subject {
        described_class.new({
          set_clause: lambda { |args|
            [" SET name = ?", args.fetch(:set).fetch(:name)]
          }
        })
      }

      it "uses set clause to get additional cql and bound variables" do
        cql = "UPDATE #{column_family_name} SET name = ? WHERE id = ?"
        expected = [cql, 'New Name', '4']
        subject.call({
          name: column_family_name,
          set: {
            name: 'New Name',
          },
          where: {
            id: '4',
          }
        }).should eq(expected)
      end
    end

    context "with :using key" do
      it "returns array of arguments with cql including using" do
        millis = (Time.mktime(2012, 11, 1, 14, 9, 9).to_f * 1000).to_i
        cql = "UPDATE #{column_family_name} USING TTL 86400 AND TIMESTAMP #{millis} AND CONSISTENCY quorum SET name = ? WHERE id = ?"
        expected = [cql, 'New Name', '1']
        subject.call({
          name: column_family_name,
          using: {
            ttl: 86400,
            timestamp: millis,
            consistency: 'quorum',
          },
          set: {
            name: 'New Name',
          },
          where: {
            id: '1',
          },
        }).should eq(expected)
      end
    end
  end
end
