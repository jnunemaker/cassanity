require 'helper'
require 'cassanity/error'

describe Cassanity::Error do
  HorribleBadThing = Class.new(StandardError)

  it "can wrap original error" do
    original = HorribleBadThing.new
    error = described_class.new(original: original)
    error.original.should eq(original)
  end

  it "defaults original to last raised exception" do
    begin
      begin
        raise HorribleBadThing, 'Yep, really bad'
      rescue StandardError => e
        raise described_class
      end
    rescue described_class => e
      e.original.should be_instance_of(HorribleBadThing)
      e.message.should eq("Original Exception: HorribleBadThing: Yep, really bad")
    end
  end

  it "does not require original error" do
    error = described_class.new(:message => 'Is this thing on?')
    error.message.should eq('Is this thing on?')
  end

  it "does not require any arguments" do
    error = described_class.new
    error.message.should eq("Something truly horrible went wrong")
  end
end
