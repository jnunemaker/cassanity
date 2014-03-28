require 'cassanity/removal'
require 'set'

module Cassanity
  def self.SetRemoval(*args)
    SetRemoval.new(*args)
  end

  class SetRemoval < Removal
    # Public: Returns a set_removal instance
    def initialize(*args)
      super(*args)
      @value = @value.to_set
    end
  end
end
