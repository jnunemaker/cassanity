module Cassanity
  module ArgumentGenerators
    class WithClause
      def call(args = {})
        with = args[:with]
        cql = ''

        return [cql] if with.nil? || with.empty?

        variables, withs = [], []

        with.each do |key, value|
          if value.is_a?(Hash)
            value.each do |sub_key, sub_value|
              withs << "#{key}:#{sub_key} = ?"
              variables << sub_value
            end
          else
            withs << "#{key} = ?"
            variables << value
          end
        end

        cql << " WITH #{withs.join(' AND ')}"

        [cql, *variables]
      end
    end
  end
end
