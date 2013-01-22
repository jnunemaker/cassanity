require 'helper'
require 'cassanity/argument_generators/batch'

describe Cassanity::ArgumentGenerators::Batch do
  describe "#call" do
    it "returns array of arguments" do
      cql = "BEGIN BATCH INSERT INTO users (id) VALUES (?) UPDATE users SET name = ? WHERE id = ? DELETE FROM users WHERE id = ? APPLY BATCH"
      subject.call({
        modifications: [
          [:insert, column_family_name: :users, data: {id: '1'}],
          [:update, column_family_name: :users, set: {name: 'GitHub'}, where: {id: '1'}],
          [:delete, column_family_name: :users, where: {id: '1'}],
        ],
      }).should eq([cql, '1', 'GitHub', '1', '1'])
    end

    context "with :column_family_name" do
      it "merges column_family_name with each set of modifications" do
        cql = "BEGIN BATCH INSERT INTO users (id) VALUES (?) UPDATE users SET name = ? WHERE id = ? APPLY BATCH"
        subject.call({
          column_family_name: :users,
          modifications: [
            [:insert, data: {id: '1'}],
            [:update, set: {name: 'GitHub'}, where: {id: '1'}],
          ],
        }).should eq([cql, '1', 'GitHub', '1'])
      end

      it "does not override command argument name" do
        cql = "BEGIN BATCH INSERT INTO users (id) VALUES (?) UPDATE other_column_family SET name = ? WHERE id = ? APPLY BATCH"
        subject.call({
          column_family_name: :users,
          modifications: [
            [:insert, data: {id: '1'}],
            [:update, column_family_name: :other_column_family, set: {name: 'GitHub'}, where: {id: '1'}],
          ],
        }).should eq([cql, '1', 'GitHub', '1'])
      end
    end

    context "with :keyspace_name" do
      it "merges column_family_name with each set of modifications" do
        cql = "BEGIN BATCH INSERT INTO analytics.users (id) VALUES (?) UPDATE analytics.users SET name = ? WHERE id = ? APPLY BATCH"
        subject.call({
          keyspace_name: :analytics,
          modifications: [
            [:insert, column_family_name: :users, data: {id: '1'}],
            [:update, column_family_name: :users, set: {name: 'GitHub'}, where: {id: '1'}],
          ],
        }).should eq([cql, '1', 'GitHub', '1'])
      end

      it "does not override command argument keyspace_name" do
        cql = "BEGIN BATCH INSERT INTO other_keyspace_name.users (id) VALUES (?) UPDATE analytics.users SET name = ? WHERE id = ? APPLY BATCH"
        subject.call({
          keyspace_name: :analytics,
          modifications: [
            [:insert, keyspace_name: :other_keyspace_name, column_family_name: :users, data: {id: '1'}],
            [:update, column_family_name: :users, set: {name: 'GitHub'}, where: {id: '1'}],
          ],
        }).should eq([cql, '1', 'GitHub', '1'])
      end
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
