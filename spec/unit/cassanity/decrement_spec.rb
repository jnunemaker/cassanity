require 'helper'
require 'cassanity/decrement'

describe Cassanity::Decrement do
  describe "self named helper method" do
    it "returns instance" do
      Cassanity::Decrement(5).should eq(described_class.new(5))
    end
  end

  describe "#initialize" do
    context "with value" do
      before do
        @instance = described_class.new(5)
      end

      it "sets value" do
        @instance.value.should be(5)
      end

      it "sets symbol" do
        @instance.symbol.should be(:-)
      end
    end

    context "without value" do
      it "defaults value to 1" do
        subject.value.should be(1)
      end
    end

    context "with nil" do
      it "raises error" do
        expect {
          described_class.new(nil)
        }.to raise_error(ArgumentError, "value cannot be nil")
      end
    end
  end

  shared_examples_for "decrement equality" do |method_name|
    it "returns true for same class and value" do
      instance = described_class.new(5)
      other = described_class.new(5)
      instance.send(method_name, other).should be_true
    end

    it "returns false for same class and different value" do
      instance = described_class.new(5)
      other = described_class.new(7)
      instance.send(method_name, other).should be_false
    end

    it "returns false for different class" do
      instance = described_class.new(5)
      other = Object.new
      instance.send(method_name, other).should be_false
    end
  end

  describe "#eql?" do
    include_examples "decrement equality", :eql?
  end

  describe "#==" do
    include_examples "decrement equality", :==
  end
end
