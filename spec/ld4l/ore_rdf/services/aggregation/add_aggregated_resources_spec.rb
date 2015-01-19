require 'spec_helper'

describe 'LD4L::OreRDF::AddAggregatedResources' do

  subject { LD4L::OreRDF::CreateAggregation.call(
      title:       "Test Title",
      description: "Test description of aggregation.",
      owner:       LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith")) }

  describe "#call" do
    it "should return an array" do
      proxy_array = LD4L::OreRDF::AddAggregatedResources.call(
          subject,
          [RDF::URI("http://example.org/individual/b1"),
           RDF::URI("http://example.org/individual/b2"),
           RDF::URI("http://example.org/individual/b3")])
      expect(proxy_array).to be_a(Array)
    end

    it "should return an array of LD4L::OreRDF::Proxy instances" do
      proxy_array = LD4L::OreRDF::AddAggregatedResources.call(
          subject,
          [RDF::URI("http://example.org/individual/b1"),
           RDF::URI("http://example.org/individual/b2"),
           RDF::URI("http://example.org/individual/b3")])
      proxy_array.each do |proxy|
        expect(proxy).to be_a(LD4L::OreRDF::Proxy)
      end
    end

    it "should add multiple resources to an empty set" do
      subject.aggregates = []
      LD4L::OreRDF::AddAggregatedResources.call(
          subject,
          [RDF::URI("http://example.org/individual/b1"),
           RDF::URI("http://example.org/individual/b2"),
           RDF::URI("http://example.org/individual/b3")])
      aggregates = subject.aggregates
      expect(aggregates).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b1"))
      expect(aggregates).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b2"))
      expect(aggregates).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b3"))
    end

    it "should add multiple resources to an existing set" do
      subject.aggregates = RDF::URI("http://example.org/individual/b1")
      LD4L::OreRDF::AddAggregatedResources.call(
          subject,
          [RDF::URI("http://example.org/individual/b2"),
           RDF::URI("http://example.org/individual/b3"),
           RDF::URI("http://example.org/individual/b4")])
      aggregates = subject.aggregates
      expect(aggregates).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b1"))
      expect(aggregates).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b2"))
      expect(aggregates).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b3"))
      expect(aggregates).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b4"))
    end

    it "should return an array of resource instances for each of the multiple resources" do
      proxy_array = LD4L::OreRDF::AddAggregatedResources.call(
          subject,
          [RDF::URI("http://example.org/individual/b1"),
           RDF::URI("http://example.org/individual/b2"),
           RDF::URI("http://example.org/individual/b3")])
      proxy_array.each do |proxy|
        expect(proxy).to be_a(LD4L::OreRDF::Proxy)
        expect(proxy.proxy_in.first).to eq subject
      end
      results = []
      proxy_array.each do |proxy|
        results << proxy.proxy_for.first
      end
      expect(results).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b1"))
      expect(results).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b2"))
      expect(results).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b3"))
    end
  end

end
