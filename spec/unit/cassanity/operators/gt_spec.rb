require 'helper'
require 'cassanity/operators/gt'

describe Cassanity::Operators::Gt do
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
