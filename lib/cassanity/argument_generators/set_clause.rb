module Cassanity
  module ArgumentGenerators
    class SetClause
      def call(args = {})
        set = args.fetch(:set)
        cql, variables, sets = '', [], []

        set.each do |key, value|
          if counter?(key, value)
            sets << "#{key} = #{value}"
          else
            sets << "#{key} = ?"
            variables << value
          end
        end
        cql << " SET #{sets.join(', ')}"


        [cql, *variables]
      end

      def counter?(key, value)
        value.is_a?(String) && value.match(/#{key}(\s+)?[\+\-](\s+)?\d/)
      end
    end
  end
end
