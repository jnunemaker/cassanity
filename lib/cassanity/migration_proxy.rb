require 'pathname'

module Cassanity
  class MigrationProxy
    include Comparable

    # Public: The full path to the migration on disk.
    attr_reader :path

    # Public: The version of the migration.
    attr_reader :version

    # Public: The name of the migration.
    attr_reader :name

    def initialize(path)
      raise ArgumentError, "path cannot be nil" if path.nil?

      basename = File.basename(path, '.rb')
      version, name = basename.split('_', 2)

      raise ArgumentError, "version cannot be nil" if version.nil?
      raise ArgumentError, "name cannot be nil" if name.nil?

      @path = Pathname(path)
      @version = version.to_i
      @name = name
    end

    def up(migrator)
      log(migrator) { build_migration(migrator).up }
    end

    def down(migrator)
      log(migrator) { build_migration(migrator).down }
    end

    def log(migrator)
      migrator.log "== #{@name}: migrating ".ljust(80, "=")
      start = Time.now
      result = yield
      duration = (Time.now - start).round(3)
      migrator.log "== #{@name}: migrated (#{duration}s) ".ljust(80, "=")
      result
    end

    def build_migration(migrator)
      migration_class.new(migrator)
    end

    def migration_class
      @migration_class ||= begin
        require path
        # TODO: handle constant not found
        Kernel.const_get(constant)
      end
    end

    def constant
      name.split('_').map { |word| word.capitalize }.join('')
    end

    def hash
      path.hash
    end

    def eql?(other)
      self.class.eql?(other.class) && version == other.version
    end
    alias_method :==, :eql?

    def <=>(other)
      @version <=> other.version
    end
  end
end
