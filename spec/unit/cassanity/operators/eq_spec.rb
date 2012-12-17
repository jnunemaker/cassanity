require 'helper'
require 'cassanity/operators/eq'

describe Cassanity::Operators::Eq do
  describe "self named helper method" do
    it "returns instance" do
      Cassanity::Operators::Eq(5).should eq(described_class.new(5))
    end
  end

  describe "#initialize" do
    subject {
      described_class.new('John')
    }

    it "sets symbol" do
      subject.symbol.should be(:"=")
    end

    it "sets value" do
      subject.value.should eq('John')
    end
  end
end
