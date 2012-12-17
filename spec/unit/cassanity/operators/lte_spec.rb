require 'helper'
require 'cassanity/operators/lte'

describe Cassanity::Operators::Lte do
  describe "#initialize" do
    subject {
      described_class.new(5)
    }

    it "sets symbol" do
      subject.symbol.should be(:<=)
    end

    it "sets value" do
      subject.value.should eq(5)
    end
  end
end
