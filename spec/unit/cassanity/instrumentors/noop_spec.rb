require 'helper'
require 'cassanity/instrumentors/noop'

describe Cassanity::Instrumentors::Noop do
  describe ".instrument" do
    context "with name" do
      it "yields block" do
        yielded = false
        described_class.instrument(:foo) { yielded = true }
        yielded.should be_true
      end
    end

    context "with name and payload" do
      it "yields block" do
        yielded = false
        described_class.instrument(:foo, {:pay => :load}) { yielded = true }
        yielded.should be_true
      end
    end
  end
end
