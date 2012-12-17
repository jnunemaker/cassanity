require 'helper'
require 'cassanity/decrement'

describe Cassanity::Decrement do
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
end
