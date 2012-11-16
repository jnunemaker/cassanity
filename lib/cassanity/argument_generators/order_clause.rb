module Cassanity
  module ArgumentGenerators
    class OrderClause

      # Internal
      def call(args = {})
        order = args[:order]

        if order.nil? || order.empty?
          ['']
        else
          [" ORDER BY #{order}"]
        end
      end
    end
  end
end
