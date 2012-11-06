require 'helper'
require 'cassanity/argument_generators/batch'

describe Cassanity::ArgumentGenerators::Batch do
  describe "#call" do
    it "returns array of arguments" do
      cql = "BEGIN BATCH INSERT INTO users (id) VALUES (?) UPDATE users SET name = ? WHERE id = ? DELETE FROM users WHERE id = ? APPLY BATCH"
      subject.call({
        modifications: [
          [:insert, name: :users, data: {id: '1'}],
          [:update, name: :users, set: {name: 'GitHub'}, where: {id: '1'}],
          [:delete, name: :users, where: {id: '1'}],
        ],
      }).should eq([cql, '1', 'GitHub', '1', '1'])
    end

    context "with :using key" do
      subject {
        described_class.new({
          using_clause: lambda { |args|
            [" USING TIMESTAMP = #{args.fetch(:using).fetch(:timestamp)}"]
          }
        })
      }

      it "uses using clause to get additional cql and bound variables" do
        cql = "BEGIN BATCH USING TIMESTAMP = 500 APPLY BATCH"
        subject.call({
          using: {
            timestamp: 500,
          },
        }).should eq([cql])
      end
    end
  end
end
