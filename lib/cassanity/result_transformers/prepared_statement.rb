require 'cassanity/prepared_statement'

module Cassanity
  module ResultTransformers
    class PreparedStatement

      # Internal: Returns the given result as a Cassanity::PreparedStatement
      # object. Meant to wrap a Cql::Client::PreparedStatement
      def call(result, args = nil)
        ::Cassanity::PreparedStatement.new result
      end
    end
  end
end
