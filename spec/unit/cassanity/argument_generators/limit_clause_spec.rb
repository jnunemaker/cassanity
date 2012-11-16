require 'helper'
require 'cassanity/argument_generators/limit_clause'

describe Cassanity::ArgumentGenerators::LimitClause do
  describe "#call" do
    context "with :limit integer value" do
      it "returns array of arguments" do
        subject.call(limit: 50).should eq([" LIMIT 50"])
      end
    end

    context "with :limit string value" do
      it "returns array of arguments" do
        subject.call(limit: '50').should eq([" LIMIT 50"])
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
