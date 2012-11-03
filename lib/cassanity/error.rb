module Cassanity
  class Error < Exception
    # Public: The original error this exception is wrapping.
    attr_reader :original

    # Public: Initializes an Error.
    #
    # args - The Hash of arguments.
    #        :original - The Exception being wrapped (optional).
    #
    # Returns the duplicated String.
    def initialize(args = {})
      @original = args.fetch(:original) { $! }
      @message = args.fetch(:message) {
        if @original
          "Original Exception: #{@original.class}: #{@original.message}"
        else
          "Something truly horrible went wrong"
        end
      }

      super @message
    end
  end

  class UnknownCommand < Error
  end
end
