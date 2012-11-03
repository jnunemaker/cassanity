require 'helper'
require 'cassanity/argument_generators/using_clause'

describe Cassanity::ArgumentGenerators::UsingClause do
  describe "#call" do
    context "with single :using option" do
      it "returns array of arguments" do
        subject.call({
          using: {
            ttl: 500,
          }
        }).should eq([
          " USING TTL 500",
        ])
      end
    end

    context "with multiple :using option" do
      it "returns array of arguments" do
        subject.call({
          using: {
            ttl: 500,
            consistency: 'quorum',
            timestamp: 1234,
          }
        }).should eq([
          " USING TTL 500 AND CONSISTENCY quorum AND TIMESTAMP 1234",
        ])
      end
    end

    context "with no arguments" do
      it "returns array of arguments where only item is empty string" do
        subject.call.should eq([""])
      end
    end

    context "with empty arguments" do
      it "returns array of arguments where only item is empty string" do
        subject.call({}).should eq([""])
      end
    end
  end
end
