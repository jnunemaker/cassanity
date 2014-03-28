require 'helper'
require 'cassanity/addition'

describe Cassanity::Addition do
  describe "self named helper method" do
    it "returns instance" do
      Cassanity::Addition('foo').should eq(described_class.new('foo'))
    end
  end

  describe "#initialize" do
    context "with value" do
      before do
        @instance = described_class.new('foo')
      end

      it "sets value" do
        @instance.value.should eq(['foo'])
      end

      it "sets symbol" do
        @instance.symbol.should be(:+)
      end
    end

    context "with multiples values" do
      before do
        @instance = described_class.new('foo', 'bar')
      end

      it "sets values" do
        @instance.value.should eq(['foo', 'bar'])
      end
    end

    context "without value" do
      it "raises error" do
        expect {
          subject.value
        }.to raise_error(ArgumentError, "value cannot be nil")
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

  shared_examples_for "addition equality" do |method_name|
    it "returns true for same class and value" do
      instance = described_class.new('foo')
      other = described_class.new('foo')
      instance.send(method_name, other).should be_true
    end

    it "returns false for same class and different value" do
      instance = described_class.new('foo')
      other = described_class.new('bar')
      instance.send(method_name, other).should be_false
    end

    it "returns false for different class" do
      instance = described_class.new('foo')
      other = Object.new
      instance.send(method_name, other).should be_false
    end
  end

  describe "#eql?" do
    include_examples "addition equality", :eql?
  end

  describe "#==" do
    include_examples "addition equality", :==
  end
end
