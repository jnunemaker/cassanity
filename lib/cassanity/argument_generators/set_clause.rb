require 'cassanity/increment'
require 'cassanity/decrement'

module Cassanity
  module ArgumentGenerators
    class SetClause

      # Internal
      def call(args = {})
        set = args.fetch(:set)
        cql, variables, sets = '', [], []

        set.each do |key, value|
          case value
          when Cassanity::Increment, Cassanity::Decrement
            sets << "#{key} = #{key} #{value.symbol} ?"
            variables << value.value
          else
            sets << "#{key} = ?"
            variables << value
          end
        end
        cql << " SET #{sets.join(', ')}"

        [cql, *variables]
      end
    end
  end
end
