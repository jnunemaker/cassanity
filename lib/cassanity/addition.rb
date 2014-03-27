module Cassanity
  def self.Addition(*args)
    Addition.new(*args)
  end

  class Addition < Operator
    # Public: Returns an addition instance
    def initialize(*args)
      values = args.flatten.compact
      raise ArgumentError.new("value cannot be nil") if values.empty?

      super :+, values
    end
  end
end
