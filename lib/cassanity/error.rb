module Cassanity
  class Error < StandardError
    # Public: The original error this exception is wrapping.
    attr_reader :original

    # Public: Initializes an Error.
    #
    # args - The Hash of arguments.
    #        :original - The Exception being wrapped (optional).
    #
    # Returns the duplicated String.
    def initialize(args = {})
      if args.is_a?(String)
        @message = args
      else
        @original = args.fetch(:original) { $! }
        @message = args.fetch(:message) {
          if @original
            "Original Exception: #{@original.class}: #{@original.message}"
          else
            "Something truly horrible went wrong"
          end
        }
      end

      super @message
    end
  end

  # Raised when an argument generator is asked to perform an unknown command.
  UnknownCommand = Class.new(Error)
end
