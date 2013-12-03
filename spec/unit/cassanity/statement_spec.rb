# encoding: utf-8
require 'helper'
require 'ostruct'
require 'cassanity/statement'

describe Cassanity::Statement do
  describe 'variable interpolation' do
    it 'interpolates strings' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?)')
      expect(stmt.interpolate(["str"])).to eq(
        "INSERT INTO foo VALUES ('str')"
      )
    end

    it 'interpolates strings, escaping single quotes' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?)')
      expect(stmt.interpolate(["testing'123"])).to eq(
        "INSERT INTO foo VALUES ('testing''123')"
      )
    end

    it 'interpolates strings containing binary data'

    it 'interpolates numerics' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?,?)')
      expect(stmt.interpolate([123, 456.78])).to eq(
        "INSERT INTO foo VALUES (123,456.78)"
      )
    end

    it 'interpolates big decimals' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?)')
      expect(stmt.interpolate([BigDecimal.new("1234.56")])).to eq(
        "INSERT INTO foo VALUES (0.123456E4)"
      )
    end

    it 'interpolates booleans' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?,?)')
      expect(stmt.interpolate([true, false])).to eq(
        "INSERT INTO foo VALUES (true,false)"
      )
    end

    it 'interpolates dates and times' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?,?)')
      expect(stmt.interpolate([Date.new(2013, 5, 1), Time.utc(2013, 5, 1)])).to eq(
        "INSERT INTO foo VALUES ('2013-05-01',1367366400000)"
      )
    end

    it 'interpolates guids' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?)')
      expect(stmt.interpolate([OpenStruct.new(to_guid: 'abc-123-def')])).to eq(
        "INSERT INTO foo VALUES (abc-123-def)"
      )
    end

    it 'interpolates arrays, recursively escaping each value' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?)')
      expect(stmt.interpolate([["str", 123]])).to eq(
        "INSERT INTO foo VALUES ('str',123)"
      )
    end

    it 'interpolates hashes, recursively escaping each key/value' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?)')
      expect(stmt.interpolate([{"foo" => 123}])).to eq(
        "INSERT INTO foo VALUES ({'foo':123})"
      )
    end

    it 'interpolates other items that can be converted to strings' do
      stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?)')

      o = Object.new
      def o.to_s; "string value"; end

      expect(stmt.interpolate([o])).to eq(
        "INSERT INTO foo VALUES ('string value')"
      )
    end

    context 'cql version 2' do
      it 'quotes big decimals values' do
        stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?)', cql_version: '2.0.0')
        expect(stmt.interpolate([BigDecimal.new("1234.56")])).to eq(
          "INSERT INTO foo VALUES ('0.123456E4')"
        )
      end

      it 'quotes boolean values' do
        stmt = Cassanity::Statement.new('INSERT INTO foo VALUES (?,?)', cql_version: '2.0.0')
        expect(stmt.interpolate([true, false])).to eq(
          "INSERT INTO foo VALUES ('true','false')"
        )
      end
    end
  end
end
