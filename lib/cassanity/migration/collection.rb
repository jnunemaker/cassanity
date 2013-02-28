require 'delegate'

module Cassanity
  class Migration
    class Collection
      include Enumerable

      def self.from_path(path)
        new Dir["#{path}/*.rb"].map { |path| Migration.from_path(path) }
      end

      def self.from_array_of_hashes(rows)
        new rows.map { |row| Migration.from_hash(row) }
      end

      def initialize(collection)
        sorted = collection.sort do |a, b|
          a.version <=> b.version
        end

        @target = sorted
      end

      def each
        @target.each { |item| yield item }
      end

      def [](*args)
        @target[*args]
      end

      def size
        @target.size
      end

      def delete_if(*args, &block)
        @target.delete_if(*args, &block)
      end

      def without(others)
        self.class.new select { |item| !others.include?(item) }
      end

      def up_to(version)
        version = version.to_i
        self.class.new select { |item| item.version <= version }
      end

      def down_to(version)
        version = version.to_i
        self.class.new select { |item| item.version > version }
      end
    end
  end
end
