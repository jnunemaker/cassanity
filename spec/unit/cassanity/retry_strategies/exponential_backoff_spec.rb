require 'helper'
require 'cassanity/retry_strategies/exponential_backoff'

describe Cassanity::RetryStrategies::ExponentialBackoff do
  subject { described_class.new }

  describe "#execute" do
    it "sleeps after a failure" do
      subject.should_receive(:sleep).once.and_raise 'Stop!'

      lambda { subject.execute { raise cassandra_error('An error!') } }.should raise_error(RuntimeError, 'Stop!')
    end

    it "retries unsuccessful calls up to :retries times, stopping on success" do
      executor = double('Executor')

      i = 0
      retries = 5

      # Raise errors for a bit, then succeed.
      executor.stub(:execute) {
        i += 1
        if i <= retries
          raise cassandra_error('An error!')
        else
          :return
        end
      }

      executor.should_receive(:execute).exactly(retries + 1).times.with('arg')

      instance = described_class.new(:retries => retries)
      instance.should_receive(:sleep).exactly(retries).times
      instance.execute { executor.execute('arg') }.should eq(:return)
    end
  end
end
