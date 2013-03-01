require 'helper'
require 'cassanity/migration'

describe Cassanity::Migration do
  describe ".from_path" do
    before do
      @result = described_class.from_path('/some/path/1_foo.rb')
    end

    it "returns instance of migration" do
      @result.should be_instance_of(described_class)
    end

    it "sets version" do
      @result.version.should be(1)
    end

    it "sets name" do
      @result.name.should eq('foo')
    end
  end

  describe "#initialize" do
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

    context "with path that is string" do
      it "sets path to pathname" do
        instance = described_class.new('/some/path/1_foo.rb')
        instance.path.should eq(Pathname('/some/path/1_foo.rb'))
      end
    end

    context "with path that is pathname" do
      it "sets path" do
        instance = described_class.new(Pathname('/some/path/1_foo.rb'))
        instance.path.should eq(Pathname('/some/path/1_foo.rb'))
      end
    end
  end

  it "responds to up" do
    instance = described_class.new('/some/path/1_foo.rb')
    instance.should respond_to(:up)
  end

  it "responds to down" do
    instance = described_class.new('/some/path/1_foo.rb')
    instance.should respond_to(:down)
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

  describe "#run" do
    context "for unsupported operation" do
      it "raises error" do
        migration = described_class.new('/some/path/1_foo.rb')
        migrator = double('Migrator', keyspace: nil)

        expect {
          migration.run(migrator, :fooooooooo)
        }.to raise_error(Cassanity::MigrationOperationNotSupported,
            ":fooooooooo is not a supported migration operation")
      end
    end
  end
end
