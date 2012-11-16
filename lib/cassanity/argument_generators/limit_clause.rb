module Cassanity
  module ArgumentGenerators
    class LimitClause

      # Internal
      def call(args = {})
        limit = args[:limit]

        if limit.nil?
          ['']
        else
          [" LIMIT #{limit}"]
        end
      end
    end
  end
end
