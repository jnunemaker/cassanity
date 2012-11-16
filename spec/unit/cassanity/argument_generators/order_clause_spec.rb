require 'helper'
require 'cassanity/argument_generators/order_clause'

describe Cassanity::ArgumentGenerators::OrderClause do
  describe "#call" do
    context "with single :order" do
      it "returns array of arguments" do
        subject.call(order: 'name').should eq([" ORDER BY name"])
      end
    end

    context "with single :order ASC" do
      it "returns array of arguments" do
        subject.call(order: 'name ASC').should eq([" ORDER BY name ASC"])
      end
    end

    context "with single :order DESC" do
      it "returns array of arguments" do
        subject.call(order: 'name DESC').should eq([" ORDER BY name DESC"])
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
