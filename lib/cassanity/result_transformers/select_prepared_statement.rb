require 'cassanity/prepared_statement'

module Cassanity
  module ResultTransformers
    class SelectPreparedStatement

      # Internal: Returns the given result as a Cassanity::PreparedStatement
      # object. Meant to wrap a Cassandra::Statements::Prepared
      def call(result, args)
        ::Cassanity::PreparedStatement.new args[:driver], result, ResultToArray.new, args
      end
    end
  end
end
