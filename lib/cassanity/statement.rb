require 'bigdecimal'
require 'date'
require 'set'
require 'time'

module Cassanity
  class Statement

    def initialize(cql, options = {})
      @cql = cql
      @options = options

      @cql_version = @options.fetch(:cql_version, '3.0.0')
    end

    def interpolate(variables)
      e = variables.to_enum
      @cql.gsub(/\?/) { quote(e.next) }
    end

    private
    def quote(var)
      if Array === var
        %([#{var.map { |v| "#{quote(v)}" }.join(',')}])
      elsif Set === var
        %({#{var.map { |v| "#{quote(v)}" }.join(',')}})
      elsif Hash === var
        %({#{var.map { |k, v| "#{quote(k)}:#{quote(v)}" }.join(',')}})
      elsif String === var
        %('#{escape_string(var)}')
      elsif BigDecimal === var && cql2?
        %('#{var.to_s}')
      elsif Numeric === var
        var.to_s
      elsif Date === var
        %('#{var.strftime('%Y-%m-%d')}')
      elsif Time === var
        (var.to_f * 1000).to_i
      elsif TrueClass === var || FalseClass === var
        if cql2?
          %('#{var.to_s}')
        else
          var.to_s
        end
      elsif var.respond_to?(:to_guid)
        var.to_guid
      elsif var.respond_to?(:to_s)
        %('#{var.to_s}')
      else
        raise ArgumentError, "Unable to escape #{var} (of type #{var.class})"
      end
    end

    def escape_string(str)
      str.gsub("'", "''")
    end

    def cql2?
      @cql_version.start_with?('2')
    end
  end
end
