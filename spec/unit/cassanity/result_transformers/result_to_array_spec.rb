require 'helper'
require 'cassanity/result_transformers/result_to_array'

describe Cassanity::ResultTransformers::ResultToArray do
  let(:result_array) {
    [{one: 1}, {two: 2}, {three: 3}]
  }

  let(:result) {
    Class.new do
      def initialize(array)
        @array = array
      end

      def fetch_hash
        @array.each do |row|
          yield row
        end
      end
    end.new(result_array)
  }

  describe "#call" do
    it "it iterates fetch_hash and returns array" do
      subject.call(result).should eq(result_array)
    end
  end
end
