require 'helper'
require 'cassanity/argument_generators/if_clause'

describe Cassanity::ArgumentGenerators::IfClause do
  describe "#call" do
    it "returns array of arguments" do
      subject.call({
        if: {
          id: '1',
        }
      }).should eq([
        ' IF "id" = ?',
        '1',
      ])
    end

    context "with nil if" do
      it "returns array with empty string" do
        subject.call.should eq([""])
      end
    end

    context "with empty if" do
      it "returns array with empty string" do
        subject.call(if: {}).should eq([""])
      end
    end

    context "with multiple conditions values" do
      it "returns array of arguments with AND separating if keys" do
        subject.call({
          if: {
            bucket: '2012',
            id: '1',
          }
        }).should eq([
          ' IF "bucket" = ? AND "id" = ?',
          '2012',
          '1',
        ])
      end
    end

    context "with a cassanity equal to operator value" do
      it "returns correct cql" do
        subject.call({
          if: {timestamp: Cassanity::Operators::Eq.new(10)},
        }).should eq([" IF timestamp = ?", 10])
      end
    end
  end
end
