require 'helper'
require 'cassanity/collection_item'

describe Cassanity::CollectionItem do
  subject {
    described_class.new(1, 'ruby')
  }

  describe "self named helper method" do
    it "returns instance" do
      Cassanity::CollectionItem(0, 'ruby').should eq(described_class.new(0, 'ruby'))
    end
  end

  describe "#initialize" do
    before do
      @instance = described_class.new(1, 'ruby')
    end

    it "sets key" do
      @instance.key.should eq(1)
    end

    it "sets value" do
      @instance.value.should eq('ruby')
    end

    context "with key nil" do
      it "raises error" do
        expect {
          described_class.new(nil, 3)
        }.to raise_error(ArgumentError, "key cannot be nil")
      end
    end

    context "with value nil" do
      it "raises error" do
        expect {
          described_class.new(3, nil)
        }.to raise_error(ArgumentError, "value cannot be nil")
      end
    end
  end

  shared_examples_for "collection item equality" do |method_name|
    it "returns true for same class, key and value" do
      instance = described_class.new(0, 'ruby')
      other = described_class.new(0, 'ruby')
      instance.send(method_name, other).should be_true
    end

    it "returns false for same class/value and different key" do
      instance = described_class.new(0, 'ruby')
      other = described_class.new(1, 'ruby')
      instance.send(method_name, other).should be_false
    end

    it "returns false for same class/key and different value" do
      instance = described_class.new(0, 'ruby')
      other = described_class.new(0, 'go')
      instance.send(method_name, other).should be_false
    end

    it "returns false for different class" do
      instance = described_class.new(1, 'ruby')
      other = Object.new
      instance.send(method_name, other).should be_false
    end
  end

  describe "#eql?" do
    include_examples "collection item equality", :eql?
  end

  describe "#==" do
    include_examples "collection item equality", :==
  end

  describe "#inspect" do
    it "return representation" do
      subject.inspect.should eq("#<Cassanity::CollectionItem:#{subject.object_id} key=1, value=\"ruby\">")
    end
  end
end
