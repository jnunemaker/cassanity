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

    context "when using :with option that has sub options" do
      it "returns array of arguments" do
        subject.call({
          with: {
            compaction_strategy_options: {
              min_compaction_threshold: 6,
              max_compaction_threshold: 40,
            },
          }
        }).should eq([
          " WITH compaction_strategy_options:min_compaction_threshold = ? AND compaction_strategy_options:max_compaction_threshold = ?",
          6,
          40,
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
