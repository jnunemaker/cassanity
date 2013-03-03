require 'helper'
require 'cassanity/migrator'

describe Cassanity::Migrator do
  describe "#initialize" do
    let(:keyspace) { double('Keyspace') }

    before do
      @result = described_class.new(keyspace, '/foo/bar')
    end

    it "sets keyspace" do
      @result.keyspace.should eq(keyspace)
    end

    it "sets migration path" do
      @result.migrations_path.should eq(Pathname('/foo/bar'))
    end
  end
end
