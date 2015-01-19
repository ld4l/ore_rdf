require 'spec_helper'

describe 'LD4L::OreRDF::FindAggregations' do

  describe "#call" do

    context "when repository is empty" do
      xit "should have tests -- SO WRITE SOME" do
      end
    end

    context "when repository has one aggregation" do
      xit "should have tests -- SO WRITE SOME" do
      end
    end

    context "when repository has multiple aggregations" do
      before(:all) do
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

      xit "should find aggregation by rdf_subject" do


        # TODO not sure how to write the criteria for this test


        aggregations = LD4L::OreRDF::FindAggregations.call(:criteria => { :subject => "http::/example.org/ag3"})
        expect(aggregations).not_to include "http::/example.org/ag1"
        expect(aggregations).not_to include "http::/example.org/ag2"
        expect(aggregations).to include "http::/example.org/ag3"
        expect(aggregations.size).to eq 1
      end

      xit "should find aggregation by title" do


        # TODO not sure how to write the criteria for this test


        aggregations = LD4L::OreRDF::FindAggregations.call(:criteria => { RDF::DC.title => "Aggregation 2"})
        expect(aggregations).not_to include "http::/example.org/ag1"
        expect(aggregations).to include "http::/example.org/ag2"
        expect(aggregations).not_to include "http::/example.org/ag3"
        expect(aggregations.size).to eq 1
      end

      it "should find all aggregations" do
        aggregations = LD4L::OreRDF::FindAggregations.call
        expect(aggregations).to include "http::/example.org/ag1"
        expect(aggregations).to include "http::/example.org/ag2"
        expect(aggregations).to include "http::/example.org/ag3"
        expect(aggregations.size).to eq 3
      end
    end

  end
end
