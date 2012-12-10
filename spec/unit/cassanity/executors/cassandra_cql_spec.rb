require 'helper'
require 'cassanity/executors/cassandra_cql'

describe Cassanity::Executors::CassandraCql do
  let(:client) { double('Client', :execute => nil) }

  let(:required_arguments) {
    {
      client: client,
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
    [:client].each do |key|
      it "raises error without :#{key} key" do
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end

    it "sets client" do
      subject.client.should eq(client)
    end

    it "defaults :argument_generators" do
      subject.argument_generators.should eq(described_class::ArgumentGenerators)
    end

    it "defaults :result_transformers" do
      subject.result_transformers.should eq(described_class::ResultTransformers)
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
      it "generates arguments based on command to argument map and passes generated arguments client execute method" do
        args = {
          command: :foo,
          arguments: {
            something: 'else',
          },
        }

        client.should_receive(:execute).with('mapped', args[:arguments])
        subject.call(args)
      end

      context "with logger" do
        let(:logger) {
          Class.new do
            attr_reader :logs

            def initialize
              @logs = []
            end

            def debug
              @logs << {debug: yield}
            end
          end.new
        }

        subject {
          described_class.new(required_arguments.merge({
            argument_generators: argument_generators,
            logger: logger,
          }))
        }

        it "logs executed arguments" do
          args = {
            command: :foo,
            arguments: {
              something: 'else',
            },
          }

          subject.call(args)

          logger.logs.should eq([
            {debug: 'Cassanity::Executors::CassandraCql executing ["mapped", {:something=>"else"}]'},
          ])
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
          client.stub(:execute => result)
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
          client.stub(:execute => result)
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
      it "generates arguments based on command to argument map and passes generated arguments client execute method" do
        expect {
          subject.call({
            command: :surprise,
          })
        }.to raise_error(Cassanity::UnknownCommand, 'Original Exception: KeyError: key not found: :surprise')
      end
    end

    context "when client raises exception" do
      it "raises Cassanity::Error" do
        client.should_receive(:execute).and_raise(Exception.new)
        expect {
          subject.call({
            command: :foo,
          })
        }.to raise_error(Cassanity::Error, /Exception: Exception/)
      end
    end
  end
end
