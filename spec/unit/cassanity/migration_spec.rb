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

  describe ".from_hash" do
    before do
      @result = described_class.from_hash({'version' => '1', 'name' => 'foo'})
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
    context "with nil version" do
      it "raises argument error" do
        expect {
          described_class.new(nil, 'foo')
        }.to raise_error(ArgumentError, 'version cannot be nil')
      end
    end

    context "with nil name" do
      it "raises argument error" do
        expect {
          described_class.new(1, nil)
        }.to raise_error(ArgumentError, 'name cannot be nil')
      end
    end

    context "with integer version" do
      before do
        @result = described_class.new(1234, 'CreateUsers')
      end

      it "sets version" do
        @result.version.should eq(1234)
      end

      it "sets name" do
        @result.name.should eq('CreateUsers')
      end
    end

    context "with string version" do
      it "sets version to integer" do
        migration = described_class.new('1234', 'CreateUsers')
        migration.version.should be(1234)
      end
    end
  end

  it "responds to up" do
    instance = described_class.new(1234, 'CreateUsers')
    instance.should respond_to(:up)
  end

  it "responds to down" do
    instance = described_class.new(1234, 'CreateUsers')
    instance.should respond_to(:down)
  end

  describe "#eql?" do
    it "returns true for same class, name, and version" do
      other = described_class.new(1, 'a')
      described_class.new(1, 'a').eql?(other).should be_true
    end

    it "returns false for different name" do
      other = described_class.new(1, 'b')
      described_class.new(1, 'a').eql?(other).should be_false
    end

    it "returns false for different version" do
      other = described_class.new(2, 'a')
      described_class.new(1, 'a').eql?(other).should be_false
    end

    it "returns false for different class" do
      other = Object.new
      described_class.new(1, 'a').eql?(other).should be_false
    end
  end

  describe "#run" do
    context "for unsupported operation" do
      it "raises error" do
        migration = described_class.new(2, 'foo')
        migrator = double('Migrator')

        expect {
          migration.run(migrator, :fooooooooo)
        }.to raise_error(Cassanity::MigrationOperationNotSupported,
            ":fooooooooo is not a supported migration operation")
      end
    end
  end
end
