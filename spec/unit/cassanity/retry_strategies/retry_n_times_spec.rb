require 'helper'
require 'cassanity/retry_strategies/retry_n_times'

describe Cassanity::RetryStrategies::RetryNTimes do
  subject { described_class.new }

  describe "#initialize" do
    it "defaults :retries to none" do
      subject.retries.should eq(0)
    end
  end

  describe "#execute" do
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
      instance.execute { executor.execute('arg') }.should eq(:return)
    end

    it "returns the last error raised when retries are exhausted" do
      executor = double('Executor')
      retries = 5
      error = cassandra_error('An error!')

      executor.should_receive(:execute).exactly(retries + 1).times.with('arg').and_raise error

      instance = described_class.new(:retries => retries)
      lambda { instance.execute { executor.execute('arg') } }.should raise_error(error)
    end
  end
end
