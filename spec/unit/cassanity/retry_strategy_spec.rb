require 'helper'
require 'cassanity/retry_strategy'

describe Cassanity::RetryStrategies::RetryStrategy do
  subject { described_class.new }

  describe "#execute" do
    it "yields to the passed block with the last error raised" do
      error = cassandra_error('An error!')
      subject.should_receive(:fail).with(1, error).and_raise 'Stop!'

      lambda { subject.execute { raise error } }.should raise_error(RuntimeError, 'Stop!')
    end

    it "only applies retry logic to CassandraCQL::Error::InvalidRequestException" do
      subject.should_not_receive(:fail)

      lambda { subject.execute { raise 'An error!' } }.should raise_error(RuntimeError, 'An error!')
    end

    it "returns the value the block returns when successful" do
      subject.should_not_receive(:fail)

      subject.execute { 1 }.should eq(1)
    end
  end
end
