require 'helper'
require 'cassanity/column_family'

describe Cassanity::Column do
  let(:name) { :age }
  let(:type) { :int }
  let(:column_family) { double('Column Family') }

  let(:required_arguments) {
    {
      name: name,
      type: type,
      column_family: column_family,
    }
  }

  subject { described_class.new(required_arguments) }

  it { should respond_to(:name) }
  it { should respond_to(:type) }
  it { should respond_to(:column_family) }

  describe "#initialize" do
    it "sets name" do
      subject.name.should eq(name)
    end

    it "sets type" do
      subject.type.should eq(type)
    end

    it "sets column_family" do
      subject.column_family.should eq(column_family)
    end

    [:name, :type, :column_family].each do |key|
      it "raises error without :#{key} key" do
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end
  end

  context "initializing with string name" do
    it "sets name to symbol" do
      instance = described_class.new(required_arguments.merge(name: 'foo'))
      instance.name.should be(:foo)
    end
  end

  context "initializing with long cassandra type" do
    described_class::Types.each do |long, short|
      it "converts #{long} to #{short}" do
        instance = described_class.new(required_arguments.merge(type: long))
        instance.type.should eq(short)
      end
    end
  end

  context "initializing with some unknown long type" do
    it "sets does not change type" do
      instance = described_class.new(required_arguments.merge(type: 'foo.bar.String'))
      instance.type.should eq('foo.bar.String')
    end
  end

  describe "#inspect" do
    it "return representation" do
      result = subject.inspect
      result.should match(/#{described_class}/)
      result.should match(/name=/)
      result.should match(/type=/)
      result.should match(/column_family=/)
    end
  end
end
