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

    context "with counter update" do
      it "returns array of arguments where counter SET is correct" do
        subject.call(set: {views: 'views + 5'}).
          should eq([" SET views = views + 5"])
      end

      it "works with no spaces" do
        subject.call(set: {views: 'views+5'}).
          should eq([" SET views = views+5"])
      end

      it "works with one or more spaces before the operator" do
        subject.call(set: {views: 'views +5'}).
          should eq([" SET views = views +5"])

        subject.call(set: {views: 'views  +5'}).
          should eq([" SET views = views  +5"])
      end

      it "works with one or more spaces after the operator" do
        subject.call(set: {views: 'views+ 5'}).
          should eq([" SET views = views+ 5"])

        subject.call(set: {views: 'views+  5'}).
          should eq([" SET views = views+  5"])
      end

      it "works with spaces after before the key" do
        subject.call(set: {views: ' views + 5'}).
          should eq([" SET views =  views + 5"])
      end

      it "works with spaces after the number" do
        subject.call(set: {views: 'views + 5 '}).
          should eq([" SET views = views + 5 "])

        subject.call(set: {views: 'views + 5  '}).
          should eq([" SET views = views + 5  "])
      end

      it "works with negative operator" do
        subject.call(set: {views: 'views - 5'}).
          should eq([" SET views = views - 5"])
      end

      it "works with multiple digit numbers" do
        subject.call(set: {views: 'views - 52737237'}).
          should eq([" SET views = views - 52737237"])
      end
    end
  end
end
