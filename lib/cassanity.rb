require 'cassanity/operators/eq'
require 'cassanity/operators/gt'
require 'cassanity/operators/gte'
require 'cassanity/operators/lt'
require 'cassanity/operators/lte'
require 'cassanity/increment'
require 'cassanity/decrement'
require 'cassanity/range'

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

  def self.range(start, finish, exclusive = false)
    Cassanity::Range.new(start, finish, exclusive)
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
  end
end

require 'cassanity/client'
