require 'spec_helper'

describe 'LD4L::OreRDF::FindAggregations' do

  describe "#call" do

    context "when repository is empty" do
      before do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end
      it "should return an empty array" do
        aggregations = LD4L::OreRDF::FindAggregations.call
        expect(aggregations).to eq []
      end
    end

    context "when repository has one aggregation" do
      before do
        p = LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith")
        p.persist!

        ag1 = LD4L::OreRDF::CreateAggregation.call(
            id:          "http::/example.org/ag1",
            title:       "Aggregation 1",
            description: "Test description of aggregation 1.",
            owner:       p )
        LD4L::OreRDF::AddAggregatedResources.call(
            ag1,
            [RDF::URI("http://example.org/individual/b11"),
             RDF::URI("http://example.org/individual/b12"),
             RDF::URI("http://example.org/individual/b13")])
        LD4L::OreRDF::PersistAggregation.call(ag1)
      end
      after do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end

      it "should return an array with 1 value" do
        aggregations = LD4L::OreRDF::FindAggregations.call
        expect(aggregations).to eq [ RDF::URI("http::/example.org/ag1") ]
      end
    end

    context "when repository has multiple aggregations" do
      before do
        p = LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith")
        p.persist!

        ag1 = LD4L::OreRDF::CreateAggregation.call(
            id:          "http::/example.org/ag1",
            title:       "Aggregation 1",
            description: "Test description of aggregation 1.",
            owner:       p )
        LD4L::OreRDF::AddAggregatedResources.call(
            ag1,
            [RDF::URI("http://example.org/individual/b11"),
             RDF::URI("http://example.org/individual/b12"),
             RDF::URI("http://example.org/individual/b13")])
        LD4L::OreRDF::PersistAggregation.call(ag1)

        ag2 = LD4L::OreRDF::CreateAggregation.call(
            id:          "http::/example.org/ag2",
            title:       "Aggregation 2",
            description: "Test description of aggregation 2.",
            owner:       p )
        LD4L::OreRDF::AddAggregatedResources.call(
            ag2,
            [RDF::URI("http://example.org/individual/b21"),
             RDF::URI("http://example.org/individual/b22"),
             RDF::URI("http://example.org/individual/b23")])
        LD4L::OreRDF::PersistAggregation.call(ag2)

        ag3 = LD4L::OreRDF::CreateAggregation.call(
            id:          "http::/example.org/ag3",
            title:       "Aggregation 3",
            description: "Test description of aggregation 3.",
            owner:       p )
        LD4L::OreRDF::AddAggregatedResources.call(
            ag3,
            [RDF::URI("http://example.org/individual/b31"),
             RDF::URI("http://example.org/individual/b32"),
             RDF::URI("http://example.org/individual/b33")])
        LD4L::OreRDF::PersistAggregation.call(ag3)
      end
      after do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end

      xit "should find aggregation by rdf_subject" do


        # TODO not sure how to write the criteria for this test


        aggregations = LD4L::OreRDF::FindAggregations.call(:criteria => { :subject => "http::/example.org/ag3"})
        expect(aggregations).not_to include "http::/example.org/ag1"
        expect(aggregations).not_to include "http::/example.org/ag2"
        expect(aggregations).to include "http::/example.org/ag3"
        expect(aggregations.size).to eq 1
      end

      it "should find aggregation by literal criteria (aka title)" do
        aggregations = LD4L::OreRDF::FindAggregations.call(:criteria => { RDF::DC.title => "Aggregation 2"})
        expect(aggregations).not_to include "http::/example.org/ag1"
        expect(aggregations).to include "http::/example.org/ag2"
        expect(aggregations).not_to include "http::/example.org/ag3"
        expect(aggregations.size).to eq 1
      end

      it "should find aggregation by rdf uri criteria (aka aggregates)" do
        aggregations = LD4L::OreRDF::FindAggregations.call(
            :criteria => { RDFVocabularies::ORE.aggregates => "http://example.org/individual/b32"})
        expect(aggregations).not_to include "http::/example.org/ag1"
        expect(aggregations).not_to include "http::/example.org/ag2"
        expect(aggregations).to include "http::/example.org/ag3"
        expect(aggregations.size).to eq 1
      end

      it "should return empty array when criteria (aka title) doesn't match any aggregations" do
        aggregations = LD4L::OreRDF::FindAggregations.call(:criteria => { RDF::DC.title => "NON-EXISTENT TITLE"})
        expect(aggregations).to eq []
      end

      it "should find all aggregations" do
        aggregations = LD4L::OreRDF::FindAggregations.call
        expect(aggregations).to include "http::/example.org/ag1"
        expect(aggregations).to include "http::/example.org/ag2"
        expect(aggregations).to include "http::/example.org/ag3"
        expect(aggregations.size).to eq 3
      end

      it "should resume all aggregation & proxies when resume = true" do
        aggregations = LD4L::OreRDF::FindAggregations.call(:resume => true)
        ag_uris = ["http::/example.org/ag1","http::/example.org/ag2","http::/example.org/ag3"]
        aggregations.each_key do |a|
          expect(a).to be_kind_of(RDF::URI)
          expect(aggregations[a]).to be_kind_of(LD4L::OreRDF::Aggregation)
          expect(ag_uris).to include aggregations[a].aggregation_resource.rdf_subject.to_str
        end
        expect(aggregations.size).to eq 3
      end

      it "should return values for specified literal property in results when criteria specified" do
        aggregations = LD4L::OreRDF::FindAggregations.call(
            :criteria   => { RDF::DC.title => "Aggregation 2" },
            :properties => { :description => RDF::DC.description } )
        expect(aggregations).to eq ( { RDF::URI("http::/example.org/ag2") => {
                                          :description => RDF::Literal("Test description of aggregation 2.") } } )
      end

      it "should return values for specified properties in results when criteria not specified" do
        aggregations = LD4L::OreRDF::FindAggregations.call(
            :properties => { :title => RDF::DC.title, :description => RDF::DC.description } )
        expect(aggregations.size).to eq 3
        expect(aggregations).to have_key RDF::URI("http::/example.org/ag1")
        expect(aggregations).to have_key RDF::URI("http::/example.org/ag2")
        expect(aggregations).to have_key RDF::URI("http::/example.org/ag3")
        expect(aggregations[RDF::URI("http::/example.org/ag1")]).to eq( {
            :title       => RDF::Literal("Aggregation 1"),
            :description => RDF::Literal("Test description of aggregation 1.") } )
        expect(aggregations[RDF::URI("http::/example.org/ag2")]).to eq( {
            :title       => RDF::Literal("Aggregation 2"),
            :description => RDF::Literal("Test description of aggregation 2.") } )
        expect(aggregations[RDF::URI("http::/example.org/ag3")]).to eq( {
            :title       => RDF::Literal("Aggregation 3"),
            :description => RDF::Literal("Test description of aggregation 3.") } )
      end


      xit "should search another repository if specified" do
        # TODO WRITE TEST
      end
    end

    context "when arguments are invalid" do
      it "should raise error when repository isn't a symbol" do
        expect{ LD4L::OreRDF::FindAggregations.call(:repository => 'BAD VALUE') }.to raise_error(
            ArgumentError,'repository must be a symbol')
      end

      it "should raise error when repository is a symbol, but isn't a registered repository" do
        expect{ LD4L::OreRDF::FindAggregations.call(:repository => :nonexistent_repo) }.to raise_error(
            ArgumentError,'repository must be a registered repository')
      end

      it "should raise error when resume is other than true or false" do
        expect{ LD4L::OreRDF::FindAggregations.call(:resume => 'BAD VALUE') }.to raise_error(
            ArgumentError,'resume must be true or false' )
      end

      xit "should raise error when criteria is other than nil or a Hash" do
        expect{ LD4L::OreRDF::FindAggregations.call(:criteria => 'BAD VALUE') }.to raise_error(
            ArgumentError,'criteria must be a hash of attribute-value pairs for searching for aggregations' )
      end
    end

  end
end
