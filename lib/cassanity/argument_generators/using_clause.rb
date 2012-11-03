module Cassanity
  module ArgumentGenerators
    class UsingClause
      def call(args = {})
        using = args[:using]
        cql, variables, usings = '', [], []

        return [cql] if using.nil? || using.empty?

        using.each do |key, value|
          usings << "#{key.upcase} #{value}"
        end

        cql << " USING #{usings.join(' AND ')}"

        [cql, *variables]
      end
    end
  end
end
