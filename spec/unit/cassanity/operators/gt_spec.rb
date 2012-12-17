require 'helper'
require 'cassanity/operators/gt'

describe Cassanity::Operators::Gt do
  describe "self named helper method" do
    it "returns instance" do
      Cassanity::Operators::Gt(5).should eq(described_class.new(5))
    end
  end

  describe "#initialize" do
    subject {
      described_class.new(5)
    }

    it "sets symbol" do
      subject.symbol.should be(:>)
    end

    it "sets value" do
      subject.value.should eq(5)
    end
  end
end
