require 'helper'
require 'cassanity/migration/collection'

describe Cassanity::Migration::Collection do

  context "initialization" do
    before do
      m1 = double('Migration', :version => 1)
      m2 = double('Migration', :version => 2)
      m3 = double('Migration', :version => 3)

      @collection = described_class.new([m2, m3, m1])
    end

    it "sorts migrations by version" do
      @collection.map(&:version).should eq([1, 2, 3])
    end
  end

  describe "#without" do
    before do
      m1 = double('Migration', :version => 1)
      m2 = double('Migration', :version => 2)
      m3 = double('Migration', :version => 3)

      @collection = described_class.new([m1, m2, m3])
      @filtered = @collection.without([m2])
    end

    it "returns new collection without passed migrations" do
      @filtered.map(&:version).should eq([1, 3])
    end

    it "does not modify original collection" do
      @collection.map(&:version).should eq([1, 2, 3])
    end
  end

  describe "#up_to" do
    before do
      m1 = double('Migration', :version => 1)
      m2 = double('Migration', :version => 2)
      m3 = double('Migration', :version => 3)

      @collection = described_class.new([m1, m2, m3])
    end

    it "returns migrations with version <= to the version provided" do
      @collection.up_to(0).map(&:version).should eq([])
      @collection.up_to(1).map(&:version).should eq([1])
      @collection.up_to(2).map(&:version).should eq([1, 2])
      @collection.up_to(3).map(&:version).should eq([1, 2, 3])
    end
  end

  describe "#down_to" do
    before do
      m1 = double('Migration', :version => 1)
      m2 = double('Migration', :version => 2)
      m3 = double('Migration', :version => 3)

      @collection = described_class.new([m1, m2, m3])
    end

    it "returns migrations with version > the version provided" do
      @collection.down_to(3).map(&:version).should eq([])
      @collection.down_to(2).map(&:version).should eq([3])
      @collection.down_to(1).map(&:version).should eq([2, 3])
      @collection.down_to(0).map(&:version).should eq([1, 2, 3])
    end
  end
end
