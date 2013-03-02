module Cassanity
  class Column

    Types = {
      "org.apache.cassandra.db.marshal.AsciiType" => :ascii,
      "org.apache.cassandra.db.marshal.BooleanType" => :boolean,
      "org.apache.cassandra.db.marshal.BytesType" => :blob,
      "org.apache.cassandra.db.marshal.CounterColumnType" => :counter,
      "org.apache.cassandra.db.marshal.DateType" => :timestamp,
      "org.apache.cassandra.db.marshal.DecimalType" => :decimal,
      "org.apache.cassandra.db.marshal.DoubleType" => :double,
      "org.apache.cassandra.db.marshal.FloatType" => :float,
      "org.apache.cassandra.db.marshal.Int32Type" => :int,
      "org.apache.cassandra.db.marshal.InetAddressType" => :inet,
      "org.apache.cassandra.db.marshal.IntegerType" => :varint,
      "org.apache.cassandra.db.marshal.LongType" => :bigint,
      "org.apache.cassandra.db.marshal.TimeUUIDType" => :timeuuid,
      "org.apache.cassandra.db.marshal.UTF8Type" => :text,
      "org.apache.cassandra.db.marshal.UUIDType" => :uuid,
    }

    # Public: The name of the column.
    attr_reader :name

    # Public: The type of the column.
    attr_reader :type

    # Public: The Cassanity::ColumnFamily the column is in.
    attr_reader :column_family

    def initialize(args = {})
      @name = args.fetch(:name).to_sym
      type = args.fetch(:type)
      @type = Types.fetch(type, type)
      @column_family = args.fetch(:column_family)
    end

    # Public
    def inspect
      attributes = [
        "name=#{@name.inspect}",
        "type=#{@type.inspect}",
        "column_family=#{@column_family.inspect}",
      ]
      "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
    end
  end
end
