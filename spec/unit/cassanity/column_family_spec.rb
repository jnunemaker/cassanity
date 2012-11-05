require 'helper'
require 'cassanity/column_family'

describe Cassanity::ColumnFamily do
  let(:column_family_name) { 'analytics' }
  let(:keyspace_name) { 'foo' }

  let(:keyspace) {
    double('Keyspace', {
      executor: executor,
      name: keyspace_name,
    })
  }

  let(:executor) {
    lambda { |args| ['GOTTA KEEP EM EXECUTED', args] }
  }

  let(:schema) { double('Schema') }

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

    it "sets schema if provided" do
      instance = described_class.new(required_arguments.merge({
        schema: schema,
      }))
      instance.schema.should eq(schema)
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
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end
  end

  describe "#schema" do
    it "returns schema if set" do
      described_class.new(required_arguments.merge({
        schema: schema,
      })).schema.should eq(schema)
    end

    it "raises error if not set" do
      expect {
        subject.schema
      }.to raise_error(Cassanity::Error, "No schema found to create #{column_family_name} column family. Please set :schema during initialization or include it as a key in #create call.")
    end
  end

  describe "#create" do
    context "with schema set during initialization" do
      subject {
        described_class.new(required_arguments.merge({
          schema: schema,
        }))
      }

      it "sends command and arguments, including schema, to executor" do
        args = {something: 'else'}
        executor.should_receive(:call).with({
          command: :column_family_create,
          arguments: args.merge({
            name: column_family_name,
            keyspace_name: keyspace_name,
            schema: schema,
          }),
        })
        subject.create(args)
      end

      it "uses passed in :schema if present" do
        schema_argument = double('Schema')
        args = {schema: schema_argument}
        executor.should_receive(:call).with({
          command: :column_family_create,
          arguments: args.merge({
            name: column_family_name,
            keyspace_name: keyspace_name,
            schema: schema_argument,
          }),
        })
        subject.create(args)
      end
    end

    context "with no schema" do
      it "raises error" do
        expect {
          subject.create
        }.to raise_error(Cassanity::Error, "No schema found to create #{column_family_name} column family. Please set :schema during initialization or include it as a key in #create call.")
      end

      it "sends passed in schema if present" do
        args = {schema: schema}
        command_arguments = args.merge({
          name: column_family_name,
          keyspace_name: keyspace_name,
          schema: schema,
        })
        executor.should_receive(:call).with({
          command: :column_family_create,
          arguments: command_arguments,
        })
        subject.create(args)
      end
    end
  end

  describe "#truncate" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :column_family_truncate,
        arguments: args.merge({
          name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.truncate(args)
    end
  end

  describe "#drop" do
    it "sends command and arguments, including :name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :column_family_drop,
        arguments: args.merge({
          name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.drop(args)
    end
  end

  describe "#insert" do
    it "sends command and arguments, including :name, to executor" do
      args = {data: {id: '1', name: 'GitHub'}}
      executor.should_receive(:call).with({
        command: :column_family_insert,
        arguments: args.merge({
          name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.insert(args)
    end
  end

  describe "#update" do
    it "sends command and arguments, including :name, to executor" do
      args = {set: {name: 'GitHub'}, where: {id: '1'}}
      executor.should_receive(:call).with({
        command: :column_family_update,
        arguments: args.merge({
          name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.update(args)
    end
  end

  describe "#delete" do
    it "sends command and arguments, including :name, to executor" do
      args = {where: {id: '1'}}
      executor.should_receive(:call).with({
        command: :column_family_delete,
        arguments: args.merge({
          name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.delete(args)
    end
  end
end
