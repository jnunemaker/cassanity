module Cassanity
  module ArgumentGenerators
    class WithClause

      # Internal
      def call(args = {})
        with = args[:with]
        cql = ''

        return [cql] if with.nil? || with.empty?

        variables, withs = [], []

        with.each do |key, value|
          if key == :compact_storage
            if value
              withs << "COMPACT STORAGE"
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
