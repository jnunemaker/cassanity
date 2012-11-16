require 'helper'
require 'cassanity/argument_generators/column_family_select'

describe Cassanity::ArgumentGenerators::ColumnFamilySelect do
  let(:column_family_name) { 'apps' }

  describe "#call" do
    it "returns array of arguments" do
      cql = "SELECT * FROM #{column_family_name}"
      expected = [cql]
      subject.call(name: column_family_name).should eq(expected)
    end

    context "with :keyspace_name" do
      it "returns array of arguments" do
        cql = "SELECT * FROM foo.#{column_family_name}"
        expected = [cql]
        subject.call({
          keyspace_name: :foo,
          name: column_family_name
        }).should eq(expected)
      end
    end

    context "with single column" do
      it "returns array of arguments querying only one column" do
        cql = "SELECT name FROM #{column_family_name}"
        expected = [cql]
        subject.call({
          name: column_family_name,
          select: :name,
        }).should eq(expected)
      end
    end

    context "with multiple columns" do
      it "returns array of arguments querying multiple columns" do
        cql = "SELECT id, name, created_at FROM #{column_family_name}"
        expected = [cql]
        subject.call({
          name: column_family_name,
          select: [:id, :name, :created_at],
        }).should eq(expected)
      end
    end

    context "with count *" do
      it "returns array of arguments querying multiple columns" do
        cql = "SELECT COUNT(*) FROM #{column_family_name}"
        expected = [cql]
        subject.call({
          name: column_family_name,
          select: 'COUNT(*)',
        }).should eq(expected)
      end
    end

    context "with count 1" do
      it "returns array of arguments querying multiple columns" do
        cql = "SELECT COUNT(1) FROM #{column_family_name}"
        expected = [cql]
        subject.call({
          name: column_family_name,
          select: 'COUNT(1)',
        }).should eq(expected)
      end
    end

    context "with WRITETIME" do
      it "returns array of arguments querying multiple columns" do
        cql = "SELECT WRITETIME(name) FROM #{column_family_name}"
        expected = [cql]
        subject.call({
          name: column_family_name,
          select: 'WRITETIME(name)',
        }).should eq(expected)
      end
    end

    context "with TTL" do
      it "returns array of arguments querying multiple columns" do
        cql = "SELECT TTL(name) FROM #{column_family_name}"
        expected = [cql]
        subject.call({
          name: column_family_name,
          select: 'TTL(name)',
        }).should eq(expected)
      end
    end

    context "with using option" do
      let(:using_clause) {
        lambda { |args| [" USING CONSISTENCY BATMAN"]}
      }

      subject { described_class.new(using_clause: using_clause) }

      it "returns array of arguments with help from using clause" do
        using = {consistency: :batman}
        cql = "SELECT * FROM #{column_family_name} USING CONSISTENCY BATMAN"
        expected = [cql]
        subject.call({
          name: column_family_name,
          using: using,
        }).should eq(expected)
      end
    end

    context "with where option" do
      let(:where_clause) {
        lambda { |args| [" WHERE foo = ?", args.fetch(:where).fetch(:foo)]}
      }

      subject { described_class.new(where_clause: where_clause) }

      it "returns array of arguments with help from where clause" do
        where = {foo: 'bar'}
        cql = "SELECT * FROM #{column_family_name} WHERE foo = ?"
        expected = [cql, 'bar']
        subject.call({
          name: column_family_name,
          where: where,
        }).should eq(expected)
      end
    end

    context "with order option" do
      let(:order_clause) {
        lambda { |args| [" ORDER BY #{args.fetch(:order)}"]}
      }

      subject { described_class.new(order_clause: order_clause) }

      it "returns array of arguments with help from order clause" do
        cql = "SELECT * FROM #{column_family_name} ORDER BY name"
        expected = [cql]
        subject.call({
          name: column_family_name,
          order: :name,
        }).should eq(expected)
      end
    end

    context "with limit option" do
      let(:limit_clause) {
        lambda { |args| [" LIMIT #{args.fetch(:limit)}"]}
      }

      subject { described_class.new(limit_clause: limit_clause) }

      it "returns array of arguments with help from limit clause" do
        cql = "SELECT * FROM #{column_family_name} LIMIT 50"
        expected = [cql]
        subject.call({
          name: column_family_name,
          limit: 50,
        }).should eq(expected)
      end
    end
  end
end
