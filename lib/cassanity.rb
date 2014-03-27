require 'cassanity/operators/eq'
require 'cassanity/operators/gt'
require 'cassanity/operators/gte'
require 'cassanity/operators/lt'
require 'cassanity/operators/lte'
require 'cassanity/increment'
require 'cassanity/decrement'
require 'cassanity/range'
require 'cassanity/addition'
require 'cassanity/removal'
require 'cassanity/set_addition'
require 'cassanity/set_removal'
require 'cassanity/collection_item'

module Cassanity
  # Public: Shortcut for returning an equality operator.
  #
  # args - The arguments to pass to the initialize method of the operator.
  #
  # Returns a Cassanity::Operators::Eq instance.
  def self.eq(*args)
    Operators::Eq.new(*args)
  end

  # Public: Shortcut for returning a less than operator.
  #
  # args - The arguments to pass to the initialize method of the operator.
  #
  # Returns a Cassanity::Operators::Lt instance.
  def self.lt(*args)
    Operators::Lt.new(*args)
  end

  # Public: Shortcut for returning a less than or equal to operator.
  #
  # args - The arguments to pass to the initialize method of the operator.
  #
  # Returns a Cassanity::Operators::Lte instance.
  def self.lte(*args)
    Operators::Lte.new(*args)
  end

  # Public: Shortcut for returning a greater than operator.
  #
  # args - The arguments to pass to the initialize method of the operator.
  #
  # Returns a Cassanity::Operators::Gt instance.
  def self.gt(*args)
    Operators::Gt.new(*args)
  end

  # Public: Shortcut for returning a greater than or equal to operator.
  #
  # args - The arguments to pass to the initialize method of the operator.
  #
  # Returns a Cassanity::Operators::Gte instance.
  def self.gte(*args)
    Operators::Gte.new(*args)
  end

  # Public: Shortcut for returning an increment value for a counter update.
  #
  # value - The value to initialize the increment with (optional, default: 1).
  #
  # Returns a Cassanity::Increment instance.
  def self.inc(value = 1)
    Increment.new(value)
  end

  # Public: Shortcut for returning a decrement value for a counter update.
  #
  # value - The value to initialize the decrement with (optional, default: 1).
  #
  # Returns a Cassanity::Decrement instance.
  def self.dec(value = 1)
    Decrement.new(value)
  end

  # Public: Shortcut for returning a range value.
  #
  # start - The start value for the range.
  # finish - The finish value for the range.
  # exclusive - The Boolean value for whether or not to include the finish of
  #             the range.
  #
  # Returns a Cassanity::Range instance.
  def self.range(start, finish, exclusive = false)
    Cassanity::Range.new(start, finish, exclusive)
  end

  # Public: Shortcut for returning an addition value for a list collection.
  #
  # values - The values to add to the list.
  #
  # Returns an Cassanity::Addition instance.
  def self.add(*values)
    Addition.new(*values)
  end

  # Public: Shortcut for returning a removal value for a list collection.
  #
  # values - The values to remove from the list.
  #
  # Returns an Cassanity::Removal instance.
  def self.remove(*values)
    Removal.new(*values)
  end

  # Public: Shortcut for returning an addition value for a set collection.
  #
  # value - The values to add to the set.
  #
  # Returns an Cassanity::SetAddition instance.
  def self.set_add(*values)
    SetAddition.new(*values)
  end

  # Public: Shortcut for returning a removal value for a set collection.
  #
  # values - The values to remove from the set.
  #
  # Returns an Cassanity::SetRemoval instance.
  def self.set_remove(*values)
    SetRemoval.new(*values)
  end

  # Public: Shortcut for returning a collection item.
  #
  # key - The item key in the list/map collection
  # value - The item value.
  #
  # Returns a Cassanity::CollectionItem instance.
  def self.item(key, value)
    CollectionItem.new(key, value)
  end

  class << self
    alias_method :equal, :eq

    alias_method :greater_than, :gt
    alias_method :greater_than_or_equal_to, :gte

    alias_method :less_than, :lt
    alias_method :less_than_or_equal_to, :lte

    alias_method :incr, :inc
    alias_method :increment, :inc

    alias_method :decr, :dec
    alias_method :decrement, :dec

    alias_method :sadd, :set_add
    alias_method :sremove, :set_remove
  end
end

require 'cassanity/client'
