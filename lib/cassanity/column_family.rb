require 'cassanity/schema'

module Cassanity
  class ColumnFamily
    # Public
    attr_reader :name

    # Public
    attr_reader :keyspace

    # Private
    attr_reader :executor

    # Private
    attr_reader :schema

    # Public: Initializes a ColumnFamily.
    #
    # args - The Hash of arguments (default: {}).
    #        :name - The String name of the column family.
    #        :keyspace - The Cassanity::Keyspace the column family is in.
    #        :executor - What will execute the queries (optional).
    #                    Must respond to `call`.
    #        :schema - The schema used to create the column family (optional).
    #
    def initialize(args = {})
      @name = args.fetch(:name).to_sym
      @keyspace = args.fetch(:keyspace)
      @executor = args.fetch(:executor) { @keyspace.executor }

      schema = args[:schema]
      @schema = if schema.is_a?(Hash)
        Cassanity::Schema.new(schema)
      else
        schema
      end
    end

    # Public: Returns true or false depending on if column family exists in
    # the keyspace.
    #
    # Returns true if column family exists, false if it does not.
    def exists?
      @executor.call({
        command: :column_families,
        arguments: {
          keyspace_name: @keyspace.name,
        },
        transformer_arguments: {
          keyspace: @keyspace,
        }
      }).any? { |column_family| column_family.name == @name }
    end

    alias_method :exist?, :exists?

    # Public: Drops column family if it exists and then calls create.
    #
    # Returns nothing.
    def recreate
      drop if exists?
      create
    end

    # Public: Creates the column family in the keyspace based on the schema.
    #
    # args - The Hash of arguments to pass to the executor. Always passes
    #        :column_family_name and :keyspace_name.
    #        :schema - The Schema to use to create the column family
    #                  (defaults to schema provided during initialization).
    #
    # Examples
    #
    #   create # uses schema from initialization
    #   create(schema: Cassanity::Schema.new(...))
    #
    # Returns nothing.
    # Raises Cassanity::Error if schema not set during initialization and also
    #   not passed in via arguments.
    def create(args = {})
      forced_arguments = {
        column_family_name: @name,
        keyspace_name: @keyspace.name,
      }
      arguments = args.merge(forced_arguments)
      arguments[:schema] = schema unless arguments[:schema]

      @executor.call({
        command: :column_family_create,
        arguments: arguments,
      })
    end

    # Public: Truncates the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :column_family_name and :keyspace_name are
    #        always included.
    #
    # Examples
    #
    #   truncate # you should rarely need more than this
    #
    # Returns whatever is returned by executor.
    def truncate(args = {})
      @executor.call({
        command: :column_family_truncate,
        arguments: args.merge({
          column_family_name: @name,
          keyspace_name: @keyspace.name,
        }),
      })
    end

    # Public: Drops the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :column_family_name and :keyspace_name are
    #        always included.
    #
    # Examples
    #
    #   drop # you should rarely need more than this
    #
    # Returns whatever is returned by executor.
    def drop(args = {})
      @executor.call({
        command: :column_family_drop,
        arguments: args.merge({
          column_family_name: @name,
          keyspace_name: @keyspace.name,
        }),
      })
    end

    # Public: Alters the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :column_family_name and :keyspace_name are
    #        always included.
    #
    # Examples
    #
    #   alter(alter: {created_at: :timestamp})
    #   alter(add: {description: :text})
    #   alter(drop: :description)
    #   alter(with: {read_repair_chance: 0.2})
    #
    # Returns whatever is returned by executor.
    def alter(args = {})
      @executor.call({
        command: :column_family_alter,
        arguments: args.merge({
          column_family_name: @name,
          keyspace_name: @keyspace.name,
        }),
      })
    end

    # Public: Creates an index
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :column_family_name and :keyspace_name are
    #        always included.
    #
    # Examples
    #
    #   create_index(column_name: 'ability_id')
    #   create_index(name: 'ability_index', column_name: 'ability_id')
    #
    # Returns whatever is returned by executor.
    def create_index(args = {})
      @executor.call({
        command: :index_create,
        arguments: args.merge({
          column_family_name: @name,
          keyspace_name: @keyspace.name,
        }),
      })
    end

    # Public: Drops an index
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}).
    #
    # Examples
    #
    #   drop_index(name: 'my_index_name')
    #
    # Returns whatever is returned by executor.
    def drop_index(args = {})
      @executor.call({
        command: :index_drop,
        arguments: args,
      })
    end

    # Public: Makes it possible to query data from the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :column_family_name and :keyspace_name are
    #        always included.
    #
    # Returns whatever is returned by executor.
    def select(args = {})
      @executor.call({
        command: :column_family_select,
        arguments: args.merge({
          column_family_name: @name,
          keyspace_name: @keyspace.name,
        })
      })
    end

    # Public: Makes it possible to insert data into the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :column_family_name and :keyspace_name are
    #        always included.
    #
    # Returns whatever is returned by executor.
    def insert(args = {})
      @executor.call({
        command: :column_family_insert,
        arguments: args.merge({
          column_family_name: @name,
          keyspace_name: @keyspace.name,
        }),
      })
    end

    # Public: Makes it possible to update data in the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :column_family_name and :keyspace_name are
    #        always included.
    #
    # Returns whatever is returned by executor.
    def update(args = {})
      @executor.call({
        command: :column_family_update,
        arguments: args.merge({
          column_family_name: @name,
          keyspace_name: @keyspace.name,
        }),
      })
    end

    # Public: Makes it possible to delete data from the column family.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}). :column_family_name and :keyspace_name are
    #        always included.
    #
    # Returns whatever is returned by executor.
    def delete(args = {})
      @executor.call({
        command: :column_family_delete,
        arguments: args.merge({
          column_family_name: @name,
          keyspace_name: @keyspace.name,
        }),
      })
    end

    # Public: Group multiple statements into a batch.
    #
    # args - The Hash of arguments to pass to the argument generator
    #        (default: {}).
    #
    # Examples
    #
    #   batch({
    #     modifications: [
    #       [:insert, column_family_name: 'apps', data: {id: '1', name: 'github'}],
    #       [:insert, column_family_name: 'apps', data: {id: '2', name: 'gist'}],
    #       [:update, column_family_name: 'apps', set: {name: 'github.com'}, where: {id: '1'}],
    #       [:delete, column_family_name: 'apps', where: {id: '2'}],
    #     ]
    #   })
    #
    # Returns whatever is returned by executor.
    def batch(args = {})
      default_arguments = {
        keyspace_name: @keyspace.name,
        column_family_name: @name,
      }

      @executor.call({
        command: :batch,
        arguments: default_arguments.merge(args),
      })
    end

    # Public: Get all columns for column family.
    #
    # Returns Array of Cassanity::Column instances.
    def columns
      @executor.call({
        command: :columns,
        arguments: {
          keyspace_name: @keyspace.name,
          column_family_name: @name,
        },
        transformer_arguments: {
          column_family: self,
        }
      })
    end

    # Internal
    def schema
      @schema || raise(Cassanity::Error.new(message: "No schema found to create #{@name} column family. Please set :schema during initialization or include it as a key in #create call."))
    end

    # Public
    def inspect
      attributes = [
        "name=#{@name.inspect}",
        "keyspace=#{@keyspace.inspect}",
        "executor=#{@executor.inspect}",
        "schema=#{@schema.inspect}",
      ]
      "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
    end
  end
end
