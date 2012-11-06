require 'helper'
require 'cassanity/argument_generators/index_create'

describe Cassanity::ArgumentGenerators::IndexCreate do
  describe "#call" do
    it "returns array of arguments" do
      cql = "CREATE INDEX ON mutants (ability_id)"
      expected = [cql]
      subject.call({
        column_family_name: :mutants,
        column_name: :ability_id,
      }).should eq(expected)
    end

    context "with :keyspace_name" do
      it "returns array of arguments" do
        cql = "CREATE INDEX ON app.mutants (ability_id)"
        expected = [cql]
        subject.call({
          keyspace_name: :app,
          column_family_name: :mutants,
          column_name: :ability_id,
        }).should eq(expected)
      end
    end

    context "with :name" do
      it "returns array of arguments with name in cql" do
        cql = "CREATE INDEX ability_index ON mutants (ability_id)"
        expected = [cql]
        subject.call({
          name: :ability_index,
          column_family_name: :mutants,
          column_name: :ability_id,
        }).should eq(expected)
      end
    end
  end
end
