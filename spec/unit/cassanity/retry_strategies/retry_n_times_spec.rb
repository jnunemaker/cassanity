require 'helper'
require 'cassanity/retry_strategies/retry_n_times'

describe Cassanity::RetryStrategies::RetryNTimes do
  subject { described_class.new }

  describe "#initialize" do
    it "defaults :retries to none" do
      described_class.new.retries.should eq(0)
    end
  end

  describe "#execute_with_retry" do
    it "retries unsuccessful calls up to :retries times, stopping on success" do
      executor = double('Executor')

      i = 0
      retries = 5

      # Raise errors for a bit, then succeed.
      executor.stub(:execute) {
        i += 1
        if i <= retries
          raise "An error!"
        else
          :return
        end
      }

      executor.should_receive(:execute).exactly(retries + 1).times.with('arg')

      instance = described_class.new(:retries => retries)
      instance.execute_with_retry(executor, ['arg']).should eq(:return)
    end

    it "returns the last error raised when retries are exhausted" do
      executor = double('Executor')
      retries = 5

      executor.should_receive(:execute).exactly(retries + 1).times.with('arg').and_raise('An error!')

      instance = described_class.new(:retries => retries)
      lambda { instance.execute_with_retry(executor, ['arg']) }.should raise_error(RuntimeError, 'An error!')
    end
  end
end
