require 'helper'
require 'cassanity/retry_strategies/exponential_backoff'

describe Cassanity::RetryStrategies::ExponentialBackoff do
  subject { described_class.new }

  describe "#execute" do
    it "sleeps after a failure" do
      subject.should_receive(:sleep).once.and_raise 'Stop!'

      lambda { subject.execute { raise cassandra_error('An error!') } }.should raise_error(RuntimeError, 'Stop!')
    end
  end
end
