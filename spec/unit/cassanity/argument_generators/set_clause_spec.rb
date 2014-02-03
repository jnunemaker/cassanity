require 'helper'
require 'cassanity/argument_generators/set_clause'

describe Cassanity::ArgumentGenerators::SetClause do
  describe "#call" do
    it "returns array of arguments" do
      subject.call({
        set: {
          name: 'GitHub',
        }
      }).should eq([
        " SET name = ?",
        'GitHub',
      ])
    end

    context "with multiple :set keys/values" do
      it "returns array of arguments where each SET is comma separated" do
        time = Time.now

        subject.call({
          set: {
            name: 'GitHub',
            created_at: time,
          }
        }).should eq([
          " SET name = ?, created_at = ?",
          'GitHub',
          time,
        ])
      end
    end

    context "with increment" do
      it "returns array of arguments with SET including counter increment" do
        subject.call(set: {views: Cassanity::Increment.new(5)}).
          should eq([" SET views = views + ?", 5])
      end
    end

    context "with decrement" do
      it "returns array of arguments with SET including counter decrement" do
        subject.call(set: {views: Cassanity::Decrement.new(3)}).
          should eq([" SET views = views - ?", 3])
      end
    end

    context "with hash" do
      it "returns array of arguments with SET including counter decrement" do
        subject.call(set: {tags: Cassanity::CollectionItem.new(3,'ruby')}).
          should eq([" SET tags[?] = ?", 3, 'ruby'])
      end
    end
  end
end
