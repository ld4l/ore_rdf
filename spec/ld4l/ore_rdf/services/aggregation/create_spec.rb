require 'spec_helper'

describe 'LD4L::OreRDF::CreateAggregation' do

  describe "#call" do
    it "should create a LD4L::OreRDF::AggregationResource instance" do
      aggregation = LD4L::OreRDF::CreateAggregation.call(
          title:       "Test Title",
          description: "Test description of aggregation.",
          owner:       LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith"))
      expect(aggregation).to be_a(LD4L::OreRDF::Aggregation)
    end

    it "should create a aggregation with passed in properties excluding an id" do
      aggregation = LD4L::OreRDF::CreateAggregation.call(
          title:       "Test Title",
          description: "Test description of aggregation.",
          owner:       LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith"))
      expect(aggregation.rdf_subject.to_s).to start_with(
          "#{LD4L::OreRDF::AggregationResource.base_uri}#{LD4L::OreRDF::AggregationResource.localname_prefix}")
      expect(aggregation.title).to eq ["Test Title"]
      expect(aggregation.description).to eq ["Test description of aggregation."]
      expect(aggregation.owner.first.rdf_subject).to eq RDF::URI("http://vivo.cornell.edu/individual/JohnSmith")
    end

    it "should create a aggregation with partial id" do
      aggregation = LD4L::OreRDF::CreateAggregation.call(
          id:          "123",
          title:       "Test Title",
          description: "Test description of aggregation.",
          owner:       LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith"))
      expect(aggregation.rdf_subject.to_s).to eq "#{LD4L::OreRDF::AggregationResource.base_uri}123"
      expect(aggregation.title).to eq ["Test Title"]
      expect(aggregation.description).to eq ["Test description of aggregation."]
      expect(aggregation.owner.first.rdf_subject).to eq RDF::URI("http://vivo.cornell.edu/individual/JohnSmith")
    end

    it "should create a aggregation with string uri id" do
      aggregation = LD4L::OreRDF::CreateAggregation.call(
          id:          "http://example.org/individual/vc123",
          title:       "Test Title",
          description: "Test description of aggregation.",
          owner:       LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith"))
      expect(aggregation.rdf_subject.to_s).to eq "http://example.org/individual/vc123"
      expect(aggregation.title).to eq ["Test Title"]
      expect(aggregation.description).to eq ["Test description of aggregation."]
      expect(aggregation.owner.first.rdf_subject).to eq RDF::URI("http://vivo.cornell.edu/individual/JohnSmith")
    end

    it "should create a aggregation with URI id" do
      aggregation = LD4L::OreRDF::CreateAggregation.call(
          id:          RDF::URI("http://example.org/individual/vc123"),
          title:       "Test Title",
          description: "Test description of aggregation.",
          owner:       LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith"))
      expect(aggregation.rdf_subject.to_s).to eq "http://example.org/individual/vc123"
      expect(aggregation.title).to eq ["Test Title"]
      expect(aggregation.description).to eq ["Test description of aggregation."]
      expect(aggregation.owner.first.rdf_subject).to eq RDF::URI("http://vivo.cornell.edu/individual/JohnSmith")
    end
  end
end
