require 'helper'
require 'cassanity/result_transformers/result_to_array'

describe Cassanity::ResultTransformers::ResultToArray do
  let(:result_array) {
    [{one: 1}, {two: 2}, {three: 3}]
  }
  let(:driver) { double Cassanity::Drivers::CassandraDriver }

  describe "#call" do
    it "returns a copy of the array" do
      subject.call(driver, result_array).should eq(result_array)
      subject.call(driver, result_array).should_not equal(result_array)
    end
  end
end
