require 'helper'
require 'cassanity/migration'

describe Cassanity::Migration do
  describe "#initialize" do
    before do
      @result = described_class.new('CreateUsers', 1234)
    end

    it "sets name" do
      @result.name.should eq('CreateUsers')
    end

    it "sets version" do
      @result.version.should eq(1234)
    end
  end
end
