require 'helper'
require 'cassanity/column_family'

describe Cassanity::ColumnFamily do
  let(:column_family_name) { :analytics }
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

    it "wraps schema if schema is hash" do
      schema = {
        primary_key: :id,
        columns: {
          id: :text,
          name: :text,
        }
      }

      instance = described_class.new(required_arguments.merge({
        schema: schema,
      }))
      instance.schema.should eq(Cassanity::Schema.new(schema))
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

  context "with string name" do
    it "converts name to symbol" do
      column_family = described_class.new(required_arguments.merge({
        name: 'foo',
      }))
      column_family.name.should be(:foo)
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

  shared_examples_for "column family existence" do |method_name|
    it "returns true if column family name included in column families" do
      executor.should_receive(:call).with({
        command: :column_families,
        arguments: {keyspace_name: keyspace.name},
        transformer_arguments: {keyspace: keyspace},
      }).and_return([
        Cassanity::ColumnFamily.new({
          name: column_family_name,
          keyspace: keyspace,
        })
      ])

      subject.send(method_name).should be_true
    end

    it "returns false if column family name not included in column families" do
      executor.should_receive(:call).with({
        command: :column_families,
        arguments: {keyspace_name: keyspace.name},
        transformer_arguments: {keyspace: keyspace},
      }).and_return([
        Cassanity::ColumnFamily.new({
          name: 'boo',
          keyspace: keyspace,
        })
      ])

      subject.send(method_name).should be_false
    end
  end

  describe "#exists?" do
    include_examples "column family existence", :exists?
  end

  describe "#exist?" do
    include_examples "column family existence", :exist?
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
            column_family_name: column_family_name,
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
            column_family_name: column_family_name,
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
          column_family_name: column_family_name,
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
    it "sends command and arguments, including :column_family_name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :column_family_truncate,
        arguments: args.merge({
          column_family_name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.truncate(args)
    end
  end

  describe "#drop" do
    it "sends command and arguments, including :column_family_name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :column_family_drop,
        arguments: args.merge({
          column_family_name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.drop(args)
    end
  end

  describe "#alter" do
    it "sends command and arguments, including :column_family_name and :keyspace_name, to executor" do
      args = {drop: :name, something: 'else'}
      executor.should_receive(:call).with({
        command: :column_family_alter,
        arguments: args.merge({
          column_family_name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.alter(args)
    end
  end

  describe "#create_index" do
    it "sends command and arguments, including :column_family_name, to executor" do
      args = {something: 'else'}
      executor.should_receive(:call).with({
        command: :index_create,
        arguments: args.merge({
          column_family_name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.create_index(args)
    end
  end

  describe "#drop_index" do
    it "sends command and arguments, including :column_family_name, to executor" do
      args = {something: 'else', name: 'users_state_idx'}
      executor.should_receive(:call).with({
        command: :index_drop,
        arguments: args,
      })
      subject.drop_index(args)
    end
  end

  describe "#insert" do
    it "sends command and arguments, including :column_family_name, to executor" do
      args = {data: {id: '1', name: 'GitHub'}}
      executor.should_receive(:call).with({
        command: :column_family_insert,
        arguments: args.merge({
          column_family_name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.insert(args)
    end
  end

  describe "#update" do
    it "sends command and arguments, including :column_family_name, to executor" do
      args = {set: {name: 'GitHub'}, where: {id: '1'}}
      executor.should_receive(:call).with({
        command: :column_family_update,
        arguments: args.merge({
          column_family_name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.update(args)
    end
  end

  describe "#delete" do
    it "sends command and arguments, including :column_family_name, to executor" do
      args = {where: {id: '1'}}
      executor.should_receive(:call).with({
        command: :column_family_delete,
        arguments: args.merge({
          column_family_name: column_family_name,
          keyspace_name: keyspace_name,
        }),
      })
      subject.delete(args)
    end
  end

  describe "#batch" do
    it "sends command and arguments, including :column_fmaily_name, to executor" do
      args = {
        keyspace_name: keyspace_name,
        column_family_name: subject.name,
        modifications: [
          [:insert, data: {id: '1', name: 'GitHub'}],
        ],
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
      result = subject.inspect
      result.should match(/#{described_class}/)
      result.should match(/name=/)
      result.should match(/keyspace=/)
      result.should match(/executor=/)
      result.should match(/schema=/)
    end
  end
end
