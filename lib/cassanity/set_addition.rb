require 'cassanity/addition'
require 'set'

module Cassanity
  def self.SetAddition(*args)
    SetAddition.new(*args)
  end

  class SetAddition < Addition
    # Public: Returns a set_addition instance
    def initialize(*args)
      super(*args)
      @value = @value.to_set
    end
  end
end
