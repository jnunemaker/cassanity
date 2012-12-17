require 'helper'
require 'cassanity/operator'

describe Cassanity::Operator do
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
end
