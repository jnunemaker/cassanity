require 'helper'
require 'cassanity/migration_proxy'

describe Cassanity::MigrationProxy do
  describe "#initialize" do
    context "with path that is pathname" do
      it "sets path" do
        instance = described_class.new(Pathname('/some/path/1_foo.rb'))
        instance.path.should eq(Pathname('/some/path/1_foo.rb'))
      end
    end

    context "with path that is string" do
      it "sets path to pathname" do
        instance = described_class.new('/some/path/1_foo.rb')
        instance.path.should eq(Pathname('/some/path/1_foo.rb'))
      end
    end

    context "with nil path" do
      it "raises argument error" do
        expect {
          described_class.new(nil)
        }.to raise_error(ArgumentError, 'path cannot be nil')
      end
    end

    context "with nil name" do
      it "raises argument error" do
        expect {
          described_class.new('/some/1')
        }.to raise_error(ArgumentError, 'name cannot be nil')
      end
    end
  end

  describe "#eql?" do
    it "returns true for same path" do
      other = described_class.new('/some/path/1_foo.rb')
      described_class.new('/some/path/1_foo.rb').eql?(other).should be_true
    end

    it "returns false for different path" do
      other = described_class.new('/some/path/1_foo.rb')
      described_class.new('/some/path/2_foo.rb').eql?(other).should be_false
    end

    it "returns false for different class" do
      other = Object.new
      described_class.new('/some/path/1_foo.rb').eql?(other).should be_false
    end
  end
end
