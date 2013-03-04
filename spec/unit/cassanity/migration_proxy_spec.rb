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

  describe "#hash" do
    it "delegates to path" do
      path = '/some/path/1_foo.rb'
      instance = described_class.new(path)
      instance.hash.should eq(path.hash)
    end
  end

  describe "#<=>" do
    it "returns -1 when version is less than other" do
      older = described_class.new(Pathname('/some/path/1_a.rb'))
      newer = described_class.new(Pathname('/some/path/2_a.rb'))
      (older <=> newer).should be(-1)
    end

    it "compares against name when version is equal to other" do
      older = described_class.new(Pathname('/some/path/1_a.rb'))
      newer = described_class.new(Pathname('/some/path/2_b.rb'))
      (older <=> newer).should eq(older.name <=> newer.name)
    end

    it "returns 1 when version is greater than other" do
      older = described_class.new(Pathname('/some/path/1_a.rb'))
      newer = described_class.new(Pathname('/some/path/2_a.rb'))
      (newer <=> older).should be(1)
    end
  end
end
