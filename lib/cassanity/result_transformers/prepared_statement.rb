require 'cassanity/prepared_statement'

module Cassanity
  module ResultTransformers
    class PreparedStatement

      # Internal: Returns the given result as a Cassanity::PreparedStatement
      # object. Meant to wrap a Cql::Client::PreparedStatement
      def call(result, args)
        ::Cassanity::PreparedStatement.new args[:driver], result
      end
    end
  end
end
