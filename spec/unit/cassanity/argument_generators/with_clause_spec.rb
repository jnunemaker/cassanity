require 'helper'
require 'cassanity/argument_generators/with_clause'

describe Cassanity::ArgumentGenerators::WithClause do
  describe "#call" do
    context "with single :with option" do
      it "returns array of arguments" do
        subject.call({
          with: {
            comment: 'Just testing',
          }
        }).should eq([
          " WITH comment = ?",
          'Just testing',
        ])
      end
    end

    context "with multiple :with option" do
      it "returns array of arguments" do
        subject.call({
          with: {
            comment: 'Just testing',
            read_repair_chance: 0.2,
          }
        }).should eq([
          " WITH comment = ? AND read_repair_chance = ?",
          'Just testing',
          0.2,
        ])
      end
    end

    context "with :compact_storage option" do
      context "set to true" do
        it "returns array of arguments converting compact storage" do
          subject.call({
            with: {
              compact_storage: true,
            }
          }).should eq([
            " WITH COMPACT STORAGE",
          ])
        end
      end

      context "set to false" do
        it "returns array of arguments not including compact storage" do
          subject.call({
            with: {
              compact_storage: false,
            }
          }).should eq([
            " WITH ",
          ])
        end
      end
    end

    context "when using :with option that has sub options" do
      it "returns array of arguments" do
        subject.call({
          with: {
            replication: {
              class: 'SimpleStrategy',
              replication_factor: 3,
            },
          }
        }).should eq([
          " WITH replication = ?",
          { class: 'SimpleStrategy', replication_factor: 3 },
        ])
      end
    end

    context "with no arguments" do
      it "returns array of arguments where only item is empty string" do
        subject.call.should eq([""])
      end
    end

    context "with empty arguments" do
      it "returns array of arguments where only item is empty string" do
        subject.call({}).should eq([""])
      end
    end
  end
end
