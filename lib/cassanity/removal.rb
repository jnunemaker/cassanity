module Cassanity
  def self.Removal(*args)
    Removal.new(*args)
  end

  class Removal < Operator
    # Public: Returns a removal instance
    def initialize(*args)
      values = args.flatten.compact
      raise ArgumentError.new("value cannot be nil") if values.empty?

      super :-, values
    end
  end
end
