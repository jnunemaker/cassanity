require 'helper'
require 'cassanity/migration/collection'

describe Cassanity::Migration::Collection do
  it "sorts migrations on initialization" do
    migration1 = double('Migration', :version => 1)
    migration2 = double('Migration', :version => 2)
    migration3 = double('Migration', :version => 3)

    collection = described_class.new([
      migration2,
      migration3,
      migration1,
    ])

    collection.map(&:version).should eq([1, 2, 3])
  end

  describe "#without" do
    it "returns new collection without passed migrations" do
      migration1 = double('Migration', :version => 1)
      migration2 = double('Migration', :version => 2)
      migration3 = double('Migration', :version => 3)

      collection = described_class.new([
        migration1,
        migration2,
        migration3,
      ])

      filtered = collection.without([migration2])
      filtered.map(&:version).should eq([1, 3])
      collection.map(&:version).should eq([1, 2, 3])
    end
  end
end
