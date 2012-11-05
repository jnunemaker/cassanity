require 'helper'
require 'cassanity/column_family'

describe Cassanity::ColumnFamily do
  let(:column_family_name) { 'analytics' }

  let(:keyspace) {
    double('Keyspace', {
      executor: executor,
    })
  }

  let(:executor) {
    lambda { |args| ['GOTTA KEEP EM EXECUTED', args] }
  }

  let(:required_arguments) {
    {
      name: column_family_name,
      keyspace: keyspace,
    }
  }

  subject { described_class.new(required_arguments) }

  it { should respond_to(:name) }
  it { should respond_to(:keyspace) }

  describe "#initialize" do
    it "sets name" do
      subject.name.should eq(column_family_name)
    end

    it "sets keyspace" do
      subject.keyspace.should eq(keyspace)
    end

    it "defaults executor to keyspace's executor" do
      subject.executor.should eq(keyspace.executor)
    end

    it "allows overriding executor" do
      other_executor = lambda { |args| }
      column_family = described_class.new(required_arguments.merge({
        executor: other_executor,
      }))
      column_family.executor.should eq(other_executor)
    end

    [:name, :keyspace].each do |key|
      it "raises error without :#{key} key" do
        expect {
          described_class.new(required_arguments.except(key))
        }.to raise_error
      end
    end
  end

  describe "#truncate" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :column_family_truncate,
        arguments: args.merge(name: column_family_name),
      })
      subject.truncate(args)
    end
  end

  describe "#drop" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :column_family_drop,
        arguments: args.merge(name: column_family_name),
      })
      subject.drop(args)
    end
  end

  describe "#insert" do
    it "sends command and arguments, including :name, to executor" do
      args = {data: {id: '1', name: 'GitHub'}}
      executor.should_receive(:call).with({
        command: :column_family_insert,
        arguments: args.merge(name: column_family_name),
      })
      subject.insert(args)
    end
  end

  describe "#update" do
    it "sends command and arguments, including :name, to executor" do
      args = {set: {name: 'GitHub'}, where: {id: '1'}}
      executor.should_receive(:call).with({
        command: :column_family_update,
        arguments: args.merge(name: column_family_name),
      })
      subject.update(args)
    end
  end

  describe "#delete" do
    it "sends command and arguments, including :name, to executor" do
      args = {where: {id: '1'}}
      executor.should_receive(:call).with({
        command: :column_family_delete,
        arguments: args.merge(name: column_family_name),
      })
      subject.delete(args)
    end
  end
end
