require 'helper'

describe Cassanity do
  describe ".eq" do
    it "returns equality operator" do
      Cassanity.eq(5).should eq(Cassanity::Operators::Eq.new(5))
    end
  end

  describe ".equal" do
    it "returns equality operator" do
      Cassanity.equal(5).should eq(Cassanity::Operators::Eq.new(5))
    end
  end

  describe ".gt" do
    it "returns greater than operator" do
      Cassanity.gt(5).should eq(Cassanity::Operators::Gt.new(5))
    end
  end

  describe ".greater_than" do
    it "returns greater than operator" do
      Cassanity.greater_than(5).should eq(Cassanity::Operators::Gt.new(5))
    end
  end

  describe ".gte" do
    it "returns greater than or equal to operator" do
      Cassanity.gte(5).should eq(Cassanity::Operators::Gte.new(5))
    end
  end

  describe ".greater_than_or_equal_to" do
    it "returns greater than operator" do
      Cassanity.greater_than_or_equal_to(5).should eq(Cassanity::Operators::Gte.new(5))
    end
  end

  describe ".lt" do
    it "returns less than operator" do
      Cassanity.lt(5).should eq(Cassanity::Operators::Lt.new(5))
    end
  end

  describe ".less_than" do
    it "returns less than operator" do
      Cassanity.less_than(5).should eq(Cassanity::Operators::Lt.new(5))
    end
  end

  describe ".lte" do
    it "returns less than or equal to operator" do
      Cassanity.lte(5).should eq(Cassanity::Operators::Lte.new(5))
    end
  end

  describe ".less_than_or_equal_to" do
    it "returns less than or equal to operator" do
      Cassanity.less_than_or_equal_to(5).should eq(Cassanity::Operators::Lte.new(5))
    end
  end

  describe ".inc" do
    it "returns increment instance" do
      Cassanity.inc(5).should eq(Cassanity::Increment.new(5))
    end

    it "returns increment instance with value of 1" do
      Cassanity.inc.should eq(Cassanity::Increment.new(1))
    end
  end

  describe ".incr" do
    it "returns increment instance" do
      Cassanity.incr(5).should eq(Cassanity::Increment.new(5))
    end

    it "returns increment instance with value of 1" do
      Cassanity.incr.should eq(Cassanity::Increment.new(1))
    end
  end

  describe ".increment" do
    it "returns increment instance" do
      Cassanity.increment(5).should eq(Cassanity::Increment.new(5))
    end

    it "returns increment instance with value of 1" do
      Cassanity.increment.should eq(Cassanity::Increment.new(1))
    end
  end

  describe ".dec" do
    it "returns decrement instance" do
      Cassanity.dec(5).should eq(Cassanity::Decrement.new(5))
    end

    it "returns decrement instance with value of 1" do
      Cassanity.dec.should eq(Cassanity::Decrement.new(1))
    end
  end

  describe ".decr" do
    it "returns decrement instance" do
      Cassanity.decr(5).should eq(Cassanity::Decrement.new(5))
    end

    it "returns decrement instance with value of 1" do
      Cassanity.decr.should eq(Cassanity::Decrement.new(1))
    end
  end

  describe ".decrement" do
    it "returns decrement instance" do
      Cassanity.decrement(5).should eq(Cassanity::Decrement.new(5))
    end

    it "returns decrement instance with value of 1" do
      Cassanity.decrement.should eq(Cassanity::Decrement.new(1))
    end
  end

  describe ".range" do
    it "returns increment instance" do
      Cassanity.range(1, 5).should eq(Cassanity::Range.new(1, 5))
    end
  end

  describe ".add" do
    it "returns addition instance" do
      Cassanity.add("value").should eq(Cassanity::Addition.new("value"))
    end
  end

  describe ".remove" do
    it "returns removal instance" do
      Cassanity.remove("value").should eq(Cassanity::Removal.new("value"))
    end
  end

  describe ".set_add" do
    it "returns set_addition instance" do
      Cassanity.set_add("value").should eq(Cassanity::SetAddition.new("value"))
    end
  end

  describe ".set_remove" do
    it "returns set_removal instance" do
      Cassanity.set_remove("value").should eq(Cassanity::SetRemoval.new("value"))
    end
  end

  describe ".sadd" do
    it "returns set_addition instance" do
      Cassanity.sadd("value").should eq(Cassanity::SetAddition.new("value"))
    end
  end

  describe ".sremove" do
    it "returns set_removal instance" do
      Cassanity.sremove("value").should eq(Cassanity::SetRemoval.new("value"))
    end
  end

  describe ".item" do
    it "returns collection item instance" do
      Cassanity.item(1,"value").should eq(Cassanity::CollectionItem.new(1,"value"))
    end
  end
end
