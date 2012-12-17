require 'helper'
require 'cassanity/argument_generators/where_clause'

describe Cassanity::ArgumentGenerators::WhereClause do
  describe "#call" do
    it "returns array of arguments" do
      subject.call({
        where: {
          id: '1',
        }
      }).should eq([
        " WHERE id = ?",
        '1',
      ])
    end

    context "with nil where" do
      it "returns array with empty string" do
        subject.call.should eq([""])
      end
    end

    context "with empty where" do
      it "returns array with empty string" do
        subject.call(where: {}).should eq([""])
      end
    end

    context "with array value for a where" do
      it "returns array of arguments using IN for key with array value" do
        subject.call({
          where: {
            id: ['1', '2', '3'],
          }
        }).should eq([
          " WHERE id IN (?)",
          ['1', '2', '3'],
        ])
      end
    end

    context "with inclusive range value for a where" do
      it "returns range comparison including end of range" do
        subject.call({
          where: {
            timestamp: Range.new(1, 3)
          },
        }).should eq([
          " WHERE timestamp >= ? AND timestamp <= ?",
          1, 3
        ])
      end
    end

    context "with exclusive range value for a where" do
      it "returns range comparison including end of range" do
        subject.call({
          where: {
            timestamp: Range.new(1, 3, true)
          },
        }).should eq([
          " WHERE timestamp >= ? AND timestamp < ?",
          1, 3
        ])
      end
    end

    context "with multiple where values" do
      it "returns array of arguments with AND separating where keys" do
        subject.call({
          where: {
            bucket: '2012',
            id: '1',
          }
        }).should eq([
          " WHERE bucket = ? AND id = ?",
          '2012',
          '1',
        ])
      end
    end
  end
end
