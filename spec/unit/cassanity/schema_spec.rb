require 'helper'
require 'cassanity/schema'

describe Cassanity::Schema do
  let(:required_arguments) {
    {
      primary_key: :id,
      columns: {
        id: :text,
        name: :text,
      }
    }
  }

  describe "#initialize" do
    [:primary_key, :columns].each do |key|
      it "raises error without :#{key} key" do
        args = required_arguments.reject { |k, v| k == key }
        expect { described_class.new(args) }.to raise_error(KeyError)
      end
    end
  end
end
