require 'helper'
require 'cassanity/executors/cassandra_cql'
require 'cassanity/instrumenters/memory'

describe Cassanity::Executors::CassandraCql do
  let(:driver) { double('Client', :execute => nil) }

  let(:required_arguments) {
    {
      driver: driver,
    }
  }

  let(:argument_generators) {
    {
      :foo => lambda { |args| ['mapped', args] },
    }
  }

  let(:result_transformers) {
    {
      :foo => lambda { |args| ['transformed', args] }
    }
  }

  subject { described_class.new(required_arguments) }

  describe "#initialize" do
    [:driver].each do |key|
      it "raises error without :#{key} key" do
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end

    it "sets driver" do
      subject.driver.should eq(driver)
    end

    it "defaults :argument_generators" do
      subject.argument_generators.should eq(described_class::DefaultArgumentGenerators)
    end

    it "defaults :result_transformers" do
      subject.result_transformers.should eq(described_class::DefaultResultTransformers)
    end

    it "defaults :instrumenter" do
      subject.instrumenter.should eq(Cassanity::Instrumenters::Noop)
    end

    it "defaults instrumenter if nil is passed in" do
      instance = described_class.new(required_arguments.merge({
        instrumenter: nil,
      }))
      instance.instrumenter.should eq(Cassanity::Instrumenters::Noop)
    end

    it "allows overriding :argument_generators" do
      instance = described_class.new(required_arguments.merge({
        argument_generators: argument_generators
      }))

      instance.argument_generators.should eq(argument_generators)
    end

    it "allows overriding :result_transformers" do
      instance = described_class.new(required_arguments.merge({
        result_transformers: result_transformers
      }))

      instance.result_transformers.should eq(result_transformers)
    end
  end

  KnownCommands = [
    :keyspaces,
    :keyspace_create,
    :keyspace_drop,
    :keyspace_use,
    :column_families,
    :column_family_create,
    :column_family_drop,
    :column_family_truncate,
    :column_family_select,
    :column_family_insert,
    :column_family_update,
    :column_family_delete,
    :column_family_alter,
    :index_create,
    :index_drop,
    :batch,
    :columns,
  ]

  KnownCommands.each do |key|
    it "responds to #{key} command by default" do
      subject.argument_generators.should have_key(key)
    end
  end

  describe "#call" do
    subject {
      described_class.new(required_arguments.merge({
        argument_generators: argument_generators,
      }))
    }

    context "for known command" do
      it "generates arguments based on command to argument map and passes generated arguments driver execute method" do
        args = {
          command: :foo,
          arguments: {
            something: 'else',
          },
        }

        driver.should_receive(:execute).with('mapped', args[:arguments])
        subject.call(args)
      end

      context "with instrumenter" do
        let(:instrumenter) { Cassanity::Instrumenters::Memory.new }

        subject {
          described_class.new(required_arguments.merge({
            argument_generators: argument_generators,
            instrumenter: instrumenter,
          }))
        }

        it "instruments executed arguments" do
          args = {
            command: :foo,
            arguments: {
              something: 'else',
            },
          }

          subject.call(args)

          event = instrumenter.events.last
          event.should_not be_nil
          event.name.should eq('cql.cassanity')
          event.payload.should eq({
            command: :foo,
            result: nil,
            cql: 'mapped',
            cql_variables: [{something: 'else'}],
          })
        end
      end

      context "with result transformer" do
        subject {
          described_class.new(required_arguments.merge({
            argument_generators: argument_generators,
            result_transformers: result_transformers,
          }))
        }

        it "returns result transformed" do
          result = double('Result')
          driver.stub(:execute => result)
          tranformer = result_transformers[:foo]

          args = {
            command: :foo,
            arguments: {
              something: 'else',
            },
          }

          subject.call(args).should eq(['transformed', result])
        end
      end

      context "without result transformer" do
        subject {
          described_class.new(required_arguments.merge({
            argument_generators: argument_generators,
            result_transformers: {},
          }))
        }

        it "returns result transformed" do
          result = double('Result')
          driver.stub(:execute => result)
          tranformer = result_transformers[:foo]

          args = {
            command: :foo,
            arguments: {
              something: 'else',
            },
          }

          subject.call(args).should eq(result)
        end
      end
    end

    context "for unknown command" do
      it "generates arguments based on command to argument map and passes
            generated arguments driver execute method" do
        expect {
          subject.call({
            command: :surprise,
          })
        }.to raise_error(Cassanity::UnknownCommand, 'Original Exception: KeyError: key not found: :surprise')
      end
    end

    context "when driver raises exception" do
      it "raises Cassanity::Error" do
        driver.should_receive(:execute).and_raise(StandardError.new)
        expect {
          subject.call({
            command: :foo,
          })
        }.to raise_error(Cassanity::Error, /StandardError: StandardError/)
      end
    end
  end

  describe "#inspect" do
    it "return representation" do
      result = subject.inspect
      result.should match(/#{described_class}/)
      result.should match(/driver=/)
    end
  end
end
