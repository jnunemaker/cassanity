require 'cassanity/prepared_statement'

module Cassanity
  module ResultTransformers
    class PreparedStatement

      # Internal: Returns the given result as a Cassanity::PreparedStatement
      # object. Meant to wrap a Cql::Client::PreparedStatement
      def call(driver, result, args = nil)
        ::Cassanity::PreparedStatement.new driver, result
      end
    end
  end
end
