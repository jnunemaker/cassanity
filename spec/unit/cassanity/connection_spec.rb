require 'helper'
require 'cassanity/connection'

describe Cassanity::Connection do
  let(:keyspace_name) { :analytics }
  let(:executor) {
    double('Executor', {
      call: nil,
    })
  }

  let(:required_arguments) {
    {
      executor: executor,
    }
  }

  subject { described_class.new(required_arguments) }

  it { should respond_to(:executor) }

  [:executor].each do |key|
    it "raises error if initialized without :#{key} key" do
      args = required_arguments.reject { |k, v| k == key }
      expect { described_class.new(args) }.to raise_error(KeyError)
    end
  end

  describe "#batch" do
    it "sends command and arguments, including :name, to executor" do
      args = {modifications: [[:insert, data: {id: '1', name: 'GitHub'}]]}
      executor.should_receive(:call).with({
        command: :batch,
        arguments: args,
      })
      subject.batch(args)
    end
  end

  describe "#keyspace" do
    context "with only name" do
      before do
        @return_value = subject.keyspace(keyspace_name)
      end

      it "returns instance of keyspace" do
        @return_value.should be_instance_of(Cassanity::Keyspace)
      end

      it "sets name" do
        @return_value.name.should eq(keyspace_name)
      end
    end

    context "with name and args" do
      before do
        @return_value = subject.keyspace(keyspace_name, {
          strategy_class: 'NetworkTopologyStrategy',
        })
      end

      it "correctly sets name" do
        @return_value.name.should eq(keyspace_name)
      end

      it "passes args to initialization" do
        @return_value.strategy_class.should eq('NetworkTopologyStrategy')
      end

      it "returns instance of keyspace" do
        @return_value.should be_instance_of(Cassanity::Keyspace)
      end
    end

    context "with single hash" do
      before do
        @return_value = subject.keyspace({
          name: keyspace_name,
          strategy_class: 'NetworkTopologyStrategy',
        })
      end

      it "returns instance of keyspace" do
        @return_value.should be_instance_of(Cassanity::Keyspace)
      end

      it "correctly sets name" do
        @return_value.name.should eq(keyspace_name)
      end

      it "passes args to initialization" do
        @return_value.strategy_class.should eq('NetworkTopologyStrategy')
      end
    end

    context "with two hashes" do
      before do
        @return_value = subject.keyspace({
          name: keyspace_name,
        }, {
          strategy_class: 'NetworkTopologyStrategy',
        })
      end

      it "returns instance of keyspace" do
        @return_value.should be_instance_of(Cassanity::Keyspace)
      end

      it "correctly sets name" do
        @return_value.name.should eq(keyspace_name)
      end

      it "passes args to initialization" do
        @return_value.strategy_class.should eq('NetworkTopologyStrategy')
      end
    end
  end

  describe "#[]" do
    before do
      @return_value = subject[keyspace_name]
    end

    it "returns instance of keyspace" do
      @return_value.should be_instance_of(Cassanity::Keyspace)
    end
  end

  describe "#inspect" do
    it "return representation" do
      result = subject.inspect
      result.should match(/#{described_class}/)
      result.should match(/executor=/)
    end
  end
end
