require 'helper'
require 'cassanity/migration'

describe Cassanity::Migration do
  describe "#initialize" do
    it "sets migrator" do
      migrator = double('Migrator')
      instance = described_class.new(migrator)
      instance.migrator.should be(migrator)
    end
  end
end
