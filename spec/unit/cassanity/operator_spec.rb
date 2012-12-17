require 'helper'
require 'cassanity/operator'

describe Cassanity::Operator do
  describe "self named helper method" do
    it "returns instance" do
      Cassanity::Operator(:<, 5).should eq(described_class.new(:<, 5))
    end
  end

  describe "#initialize" do
    before do
      @instance = described_class.new('<', 5)
    end

    it "sets symbol" do
      @instance.symbol.should eq('<')
    end

    it "sets value" do
      @instance.value.should be(5)
    end
  end

  shared_examples_for "operator equality" do |method_name|
    it "returns true for same class, symbol and value" do
      instance = described_class.new(:<, 5)
      other = described_class.new(:<, 5)
      instance.send(method_name, other).should be_true
    end

    it "returns false for same class/value and different symbol" do
      instance = described_class.new(:<, 5)
      other = described_class.new(:>, 5)
      instance.send(method_name, other).should be_false
    end

    it "returns false for same class/symbol and different value" do
      instance = described_class.new(:<, 5)
      other = described_class.new(:>, 7)
      instance.send(method_name, other).should be_false
    end

    it "returns false for different class" do
      instance = described_class.new(:<, 5)
      other = Object.new
      instance.send(method_name, other).should be_false
    end
  end

  describe "#eql?" do
    include_examples "operator equality", :eql?
  end

  describe "#==" do
    include_examples "operator equality", :==
  end
end
