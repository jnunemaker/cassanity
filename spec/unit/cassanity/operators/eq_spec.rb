require 'helper'
require 'cassanity/operators/eq'

describe Cassanity::Operators::Eq do
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
