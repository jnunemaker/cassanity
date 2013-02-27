require 'delegate'

module Cassanity
  class Migration
    class Collection < SimpleDelegator
      def self.from_path(path)
        paths = Dir["#{path}/*.rb"]
        migrations = paths.map { |path| Migration.from_path(path) }
        new(migrations)
      end

      def self.from_column_family(column_family)
        rows = column_family.select
        migrations = rows.map { |row| Migration.from_hash(row) }
        new(migrations)
      end

      def initialize(collection)
        sorted = collection.sort do |a, b|
          a.version <=> b.version
        end

        super sorted
      end

      def without(others)
        dup.delete_if { |item| others.include?(item) }
      end
    end
  end
end
