module Cassanity
  def self.CollectionItem(*args)
    CollectionItem.new(*args)
  end

  class CollectionItem
    # Internal
    attr_reader :key

    # Internal
    attr_reader :value

    # Public: Returns a collection item instance
    def initialize(key, value)
      raise ArgumentError.new("key cannot be nil") if key.nil?
      raise ArgumentError.new("value cannot be nil") if value.nil?
      
      @key   = key
      @value = value
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        value == other.value &&
        key == other.key
    end

    alias_method :==, :eql?

    # Public
    def inspect
      attributes = [
        "key=#{key.inspect}",
        "value=#{value.inspect}",
      ]
      "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
    end
  end
end
