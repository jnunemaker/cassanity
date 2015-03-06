require 'cassanity/column_family'

module Cassanity
  class Keyspace
    # Public
    attr_reader :name

    # Internal
    attr_reader :executor

    # Internal
    attr_reader :replication

    # Public: Initializes a Keyspace.
    #
    # args - The Hash of arguments (default: {}).
    #        :name - The String name of the keyspace.
    #        :executor - What will execute the queries. Must respond to `call`.
    #        :replication - Hash of replication options (e.g., :class,
    #                       :replication_factor)
    #
    def initialize(args = {})
      @name = args.fetch(:name).to_sym
      @executor = args.fetch(:executor)
      @replication = args.fetch(:replication, {})
    end

    # Public: Returns true or false depending on if keyspace exists in the
    # current cluster.
    #
    # Returns true if keyspace exists, false if it does not.
    def exists?
      @executor.call({
        command: :keyspaces,
        transformer_arguments: {
          executor: @executor,
        },
      }).any? { |keyspace| keyspace.name == @name }
    end

    alias_method :exist?, :exists?

    # Public: Creates the keyspace
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :keyspace_name is always included.
    #
    # Examples
    #
    #   create # uses options from initialization
    #
    #   # override options from initialization
    #   create({
    #     replication: {
    #       class: 'NetworkTopologyStrategy',
    #       dc1: 1,
    #       dc2: 3,
    #     }
    #   })
    #
    # Returns whatever is returned by executor.
    def create(args = {})
      create_arguments = {}.merge(args)
      create_arguments[:replication] = @replication.merge(create_arguments[:replication] || {})
      create_arguments[:keyspace_name] = @name

      @executor.call({
        command: :keyspace_create,
        arguments: create_arguments,
      })
    end

    # Public: Drops keyspace if it exists and then calls create.
    #
    # Returns nothing.
    def recreate
      drop if exists?
      create
    end

    # Public: Uses a keyspace
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :keyspace_name is always included.
    #
    # Examples
    #
    #   use # you shouldn't really ever need more than this
    #
    # Returns whatever is returned by executor.
    def use(args = {})
      @executor.call({
        command: :keyspace_use,
        arguments: args.merge({
          keyspace_name: @name,
        }),
      })
    end

    # Public: Drops a keyspace
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :keyspace_name is always included.
    #
    # Examples
    #
    #   drop # you shouldn't really ever need more than this
    #
    # Returns whatever is returned by executor.
    def drop(args = {})
      @executor.driver.use 'system'
      @executor.call({
        command: :keyspace_drop,
        arguments: args.merge({
          keyspace_name: @name,
        }),
      })
    end

    # Public: Get all column families for keyspace.
    #
    # Returns Array of Cassanity::ColumnFamily instances.
    def column_families
      @executor.call({
        command: :column_families,
        arguments: {
          keyspace_name: @name,
        },
        transformer_arguments: {
          keyspace: self,
        }
      })
    end

    # Public: Get a column family instance
    #
    # name_or_args - The String name of the column family or a Hash which has
    #                the name key and possibly other arguments.
    # args - The Hash of arguments to use for ColumnFamily initialization
    #        (optional, default: {}). :keyspace is always included.
    #
    # Returns a Cassanity::ColumnFamily instance.
    def column_family(name_or_args, args = {})
      column_family_args = if name_or_args.is_a?(Hash)
        name_or_args.merge(args)
      else
        args.merge(name: name_or_args)
      end

      ColumnFamily.new(column_family_args.merge(keyspace: self))
    end
    alias_method :table, :column_family
    alias_method :[], :column_family

    # Public: Group multiple statements into a batch.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}).
    #
    # Examples
    #
    #   batch({
    #     modifications: [
    #       [:insert, name: 'apps', data: {id: '1', name: 'github'}],
    #       [:insert, name: 'apps', data: {id: '2', name: 'gist'}],
    #       [:update, name: 'apps', set: {name: 'github.com'}, where: {id: '1'}],
    #       [:delete, name: 'apps', where: {id: '2'}],
    #     ]
    #   })
    #
    # Returns whatever is returned by executor.
    def batch(args = {})
      default_arguments = {
        keyspace_name: @name,
      }

      @executor.call({
        command: :batch,
        arguments: default_arguments.merge(args),
      })
    end

    # Public
    def inspect
      attributes = [
        "name=#{@name.inspect}",
      ]
      "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
    end
  end
end
