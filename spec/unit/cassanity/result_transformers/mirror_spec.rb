require 'helper'
require 'cassanity/result_transformers/mirror'

describe Cassanity::ResultTransformers::Mirror do
  describe "#call" do
    it "returns whatever is passed it" do
      [1, '2', ['something'], {something: 'else'}].each do |result|
        subject.call(double(Cassanity::Cql::ReconnectableDriver), result).should be(result)
      end
    end
  end
end
