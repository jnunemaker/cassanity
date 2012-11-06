module Cassanity
  module ArgumentGenerators
    class UsingClause

      # Internal
      def call(args = {})
        using = args[:using]
        cql = ''

        return [cql] if using.nil? || using.empty?

        variables, usings = [], []

        using.each do |key, value|
          usings << "#{key.upcase} #{value}"
        end

        cql << " USING #{usings.join(' AND ')}"

        [cql, *variables]
      end
    end
  end
end
