require 'helper'
require 'cassanity/keyspace'

describe Cassanity::Keyspace do
  let(:keyspace_name) { :analytics }

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

    it "sets class if provided" do
      instance = described_class.new(required_arguments.merge({
        replication: {class: 'NetworkTopologyStrategy'},
      }))

      instance.replication.should eq(class: 'NetworkTopologyStrategy')
    end

    it "sets strategy options if provided" do
      instance = described_class.new(required_arguments.merge({
        replication: {
          dc1: 3,
          dc2: 5,
        },
      }))

      instance.replication.should eq({
        dc1: 3,
        dc2: 5,
      })
    end
  end

  context "with string name" do
    it "converts name to symbol" do
      instance = described_class.new(required_arguments.merge({
        name: 'foo',
      }))
      instance.name.should be(:foo)
    end
  end

  describe "#column_family" do
    let(:column_family_name) { :apps }

    context "with only name" do
      before do
        @return_value = subject.column_family(column_family_name)
      end

      it "returns instance of column family" do
        @return_value.should be_instance_of(Cassanity::ColumnFamily)
      end

      it "sets name" do
        @return_value.name.should eq(column_family_name)
      end
    end

    context "with name and hash" do
      let(:schema) { double('Schema') }

      before do
        @return_value = subject.column_family(column_family_name, {
          schema: schema,
        })
      end

      it "passes args to initialization" do
        @return_value.schema.should eq(schema)
      end

      it "sets name" do
        @return_value.name.should eq(column_family_name)
      end

      it "returns instance of column family" do
        @return_value.should be_instance_of(Cassanity::ColumnFamily)
      end
    end

    context "with hash" do
      let(:schema) { double('Schema') }

      before do
        @return_value = subject.column_family({
          name: column_family_name,
          schema: schema,
        })
      end

      it "passes args to initialization" do
        @return_value.schema.should eq(schema)
      end

      it "sets name" do
        @return_value.name.should eq(column_family_name)
      end

      it "returns instance of column family" do
        @return_value.should be_instance_of(Cassanity::ColumnFamily)
      end
    end

    context "with two hashes" do
      let(:schema) { double('Schema') }

      before do
        @return_value = subject.column_family({
          name: column_family_name,
        }, {
          schema: schema,
        })
      end

      it "passes args to initialization" do
        @return_value.schema.should eq(schema)
      end

      it "sets name" do
        @return_value.name.should eq(column_family_name)
      end

      it "returns instance of column family" do
        @return_value.should be_instance_of(Cassanity::ColumnFamily)
      end
    end
  end

  describe "#table" do
    let(:column_family_name) { :apps }

    before do
      @return_value = subject.table(column_family_name)
    end

    it "sets name" do
      @return_value.name.should eq(column_family_name)
    end

    it "returns instance of column family" do
      @return_value.should be_instance_of(Cassanity::ColumnFamily)
    end
  end

  describe "#[]" do
    let(:column_family_name) { :apps }

    before do
      @return_value = subject[column_family_name]
    end

    it "sets name" do
      @return_value.name.should eq(column_family_name)
    end

    it "returns instance of column family" do
      @return_value.should be_instance_of(Cassanity::ColumnFamily)
    end
  end

  shared_examples_for "keyspace existence" do |method_name|
    it "returns true if name in existing keyspace names" do
      executor.should_receive(:call).with({
        command: :keyspaces,
        transformer_arguments: {
          executor: executor,
        },
      }).and_return([
        Cassanity::Keyspace.new({name: keyspace_name, executor: executor}),
      ])
      subject.send(method_name).should be_true
    end

    it "returns false if name not in existing keyspace names" do
      executor.should_receive(:call).with({
        command: :keyspaces,
        transformer_arguments: {
          executor: executor,
        },
      }).and_return([
        Cassanity::Keyspace.new({name: :batman, executor: executor}),
      ])
      subject.send(method_name).should be_false
    end

    it "returns false if no keyspaces" do
      executor.should_receive(:call).with({
        command: :keyspaces,
        transformer_arguments: {
          executor: executor,
        },
      }).and_return([])
      subject.send(method_name).should be_false
    end
  end

  describe "#exists?" do
    include_examples "keyspace existence", :exists?
  end

  describe "#exist?" do
    include_examples "keyspace existence", :exist?
  end

  describe "#create" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :keyspace_create,
        arguments: args.merge(keyspace_name: keyspace_name, replication: {}),
      })
      subject.create(args)
    end

    it "includes strategy class and options if present" do
      args = {something: 'else'}

      executor.should_receive(:call).with({
        command: :keyspace_create,
        arguments: args.merge({
          keyspace_name: keyspace_name,
          replication: {class: 'NetworkTopologyStrategy', replication_factory: 3},
        }),
      })

      instance = described_class.new(required_arguments.merge({
        replication: {class: 'NetworkTopologyStrategy', replication_factory: 3},
      }))

      instance.create(args)
    end

    it "merges strategy options in args with initialized strategy options" do
      args = {replication: {dc1: 1}}

      executor.should_receive(:call).with({
        command: :keyspace_create,
        arguments: {
          keyspace_name: keyspace_name,
          replication: {dc1: 1, dc2: 2},
        },
      })

      instance = described_class.new(required_arguments.merge({
        replication: {dc2: 2},
      }))

      instance.create(args)
    end
  end

  describe "#recreate" do
    context "for existing keyspace" do
      before do
        subject.stub(:exists? => true)
      end

      it "performs drop" do
        subject.should_receive(:drop)
        subject.recreate
      end

      it "performs create" do
        subject.should_receive(:create)
        subject.recreate
      end
    end

    context "for non-existing keyspace" do
      before do
        subject.stub(:exists? => false)
      end

      it "does not perform drop" do
        subject.should_not_receive(:drop)
        subject.recreate
      end

      it "performs create" do
        subject.should_receive(:create)
        subject.recreate
      end
    end
  end

  describe "#use" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :keyspace_use,
        arguments: args.merge(keyspace_name: keyspace_name),
      })
      subject.use(args)
    end
  end

  describe "#drop" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :keyspace_drop,
        arguments: args.merge(keyspace_name: keyspace_name),
      })
      subject.drop(args)
    end
  end

  describe "#batch" do
    it "sends command and arguments, including :keyspace_name, to executor" do
      args = {
        keyspace_name: subject.name,
        modifications: [
          [:insert, data: {id: '1', name: 'GitHub'}],
        ]
      }
      executor.should_receive(:call).with({
        command: :batch,
        arguments: args,
      })
      subject.batch(args)
    end
  end

  describe "#inspect" do
    it "return representation" do
      subject.inspect.should eq("#<Cassanity::Keyspace:#{subject.object_id} name=:analytics>")
    end
  end
end
