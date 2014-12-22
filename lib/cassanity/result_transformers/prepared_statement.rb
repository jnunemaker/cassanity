require 'cassanity/prepared_statement'

module Cassanity
  module ResultTransformers
    class PreparedStatement

      # Internal: Returns whatever result is passed to it. This is used as the
      # default result transformer when a command does not have one.
      def call(result, args = nil)
        ::Cassanity::PreparedStatement.new result, args.fetch(:fields)
      end
    end
  end
end
