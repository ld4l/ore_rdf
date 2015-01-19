require 'spec_helper'

describe 'LD4L::OreRDF::Aggregation::AddAggregatedResource' do

  subject { LD4L::OreRDF::CreateAggregation.call(
      title:       "Test Title",
      description: "Test description of aggregation.",
      owner:       LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith")) }

  describe "#call" do
    it "should return a LD4L::OreRDF::Proxy instance" do
      proxy = LD4L::OreRDF::AddAggregatedResource.call(subject,RDF::URI("http://example.org/individual/b1"))
      expect(proxy).to be_a(LD4L::OreRDF::Proxy)
    end

    it "should add a single resource to an empty set" do
      subject.aggregates = []
      LD4L::OreRDF::AddAggregatedResource.call(subject,RDF::URI("http://example.org/individual/b1"))
      expect(subject.aggregates.first.rdf_subject).to eq RDF::URI("http://example.org/individual/b1")
    end

    it "should add a single resource to an existing set" do
      subject.aggregates = RDF::URI("http://example.org/individual/b1")
      LD4L::OreRDF::AddAggregatedResource.call(subject,RDF::URI("http://example.org/individual/b2"))
      expect(subject.aggregates[0].rdf_subject).to eq RDF::URI("http://example.org/individual/b1")
      expect(subject.aggregates[1].rdf_subject).to eq RDF::URI("http://example.org/individual/b2")
    end

    it "should generate the resource instance for a single resource" do
      proxy = LD4L::OreRDF::AddAggregatedResource.call(subject,RDF::URI("http://example.org/individual/b1"))
      expect(proxy.proxy_for.first.rdf_subject).to eq RDF::URI("http://example.org/individual/b1")
      expect(proxy.proxy_in.first).to eq subject
    end
  end

end