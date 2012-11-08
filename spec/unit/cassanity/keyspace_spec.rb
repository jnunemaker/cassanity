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

    it "sets executor" do
      subject.executor.should eq(executor)
    end

    [:name, :executor].each do |key|
      it "raises error without :#{key} key" do
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end

    it "sets strategy_class if provided" do
      instance = described_class.new(required_arguments.merge({
        strategy_class: 'NetworkTopologyStrategy',
      }))

      instance.strategy_class.should eq('NetworkTopologyStrategy')
    end

    it "sets strategy_options if provided" do
      instance = described_class.new(required_arguments.merge({
        strategy_options: {
          dc1: 3,
          dc2: 5,
        },
      }))

      instance.strategy_options.should eq({
        dc1: 3,
        dc2: 5,
      })
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

  describe "#exists?" do
    it "returns true if name in existing keyspace names" do
      executor.should_receive(:call).with(command: :keyspaces).and_return([
        {'name' => keyspace_name.to_s},
      ])
      subject.exists?.should be_true
    end

    it "returns false if name not in existing keyspace names" do
      executor.should_receive(:call).with(command: :keyspaces).and_return([
        {'name' => 'batman'},
      ])
      subject.exists?.should be_false
    end

    it "returns false if no keyspaces" do
      executor.should_receive(:call).with(command: :keyspaces).and_return([])
      subject.exists?.should be_false
    end
  end

  describe "#create" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :keyspace_create,
        arguments: args.merge(name: keyspace_name),
      })
      subject.create(args)
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
