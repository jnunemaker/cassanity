require 'helper'
require 'cassanity/keyspace'

describe Cassanity::Keyspace do
  let(:keyspace_name) { 'analytics' }

  let(:executor) {
    lambda { |args| ['GOTTA KEEP EM EXECUTED', args] }
  }

  let(:required_arguments) {
    {
      name: keyspace_name,
      executor: executor,
    }
  }

  subject { described_class.new(required_arguments) }

  it { should respond_to(:name) }
  it { should respond_to(:executor) }

  describe "#initialize" do
    it "sets name" do
      subject.name.should eq(keyspace_name)
    end

    [:name, :executor].each do |key|
      it "raises error without :#{key} key" do
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end
  end

  describe "#column_family" do
    let(:column_family_name) { 'apps' }

    before do
      @return_value = subject.column_family(column_family_name)
    end

    it "returns instance of column family" do
      @return_value.should be_instance_of(Cassanity::ColumnFamily)
    end

    context "with args" do
      let(:schema) { double('Schema') }

      before do
        @return_value = subject.column_family(column_family_name, {
          schema: schema,
        })
      end

      it "passes args to initialization" do
        @return_value.schema.should eq(schema)
      end

      it "returns instance of column family" do
        @return_value.should be_instance_of(Cassanity::ColumnFamily)
      end
    end
  end

  describe "#table" do
    let(:column_family_name) { 'apps' }

    before do
      @return_value = subject.table(column_family_name)
    end

    it "returns instance of column family" do
      @return_value.should be_instance_of(Cassanity::ColumnFamily)
    end
  end

  describe "#[]" do
    let(:column_family_name) { 'apps' }

    before do
      @return_value = subject[column_family_name]
    end

    it "returns instance of column family" do
      @return_value.should be_instance_of(Cassanity::ColumnFamily)
    end
  end

  describe "#use" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :keyspace_use,
        arguments: args.merge(name: keyspace_name),
      })
      subject.use(args)
    end
  end

  describe "#drop" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :keyspace_drop,
        arguments: args.merge(name: keyspace_name),
      })
      subject.drop(args)
    end
  end
end
