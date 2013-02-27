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

  it "responds to up" do
    instance = described_class.new('CreateUsers', 1234)
    instance.should respond_to(:up)
  end

  it "responds to down" do
    instance = described_class.new('CreateUsers', 1234)
    instance.should respond_to(:down)
  end
end
