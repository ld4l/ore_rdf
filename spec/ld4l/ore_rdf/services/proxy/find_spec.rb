require 'spec_helper'

describe 'LD4L::OreRDF::FindProxies' do

  describe "#call" do

    context "when repository is empty" do
      before do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end
      it "should return an empty array" do
        proxies = LD4L::OreRDF::FindProxies.call(
            :aggregation => 'http://example.org/NON-EXISTING-AGGREGATION' )
        expect(proxies).to eq []
      end
    end

    context "when repository has one aggregation with one proxy" do
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
            [RDF::URI("http://example.org/individual/b11")])
        LD4L::OreRDF::PersistAggregation.call(ag1)
      end
      after do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end

      it "should return an array with 1 value" do
        proxies = LD4L::OreRDF::FindProxies.call(
            :aggregation => 'http::/example.org/ag1' )
        expect(proxies.size).to eq 1
        expect(proxies.first).to be_a_kind_of RDF::URI
        pr = LD4L::OreRDF::ProxyResource.new(proxies.first)
        expect(pr.proxy_in.first.rdf_subject.to_s).to eq "http::/example.org/ag1"
        expect(pr.proxy_for.first).to eq "http://example.org/individual/b11"
      end
    end

    context "when repository has multiple aggregations with proxies" do
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


        # proxies = LD4L::OreRDF::FindAggregations.call(
        #     :aggregation => "http::/example.org/ag2",
        #     :criteria    => { :subject => "http::/example.org/individual/v21" }  )
        # expect(proxies).not_to include "http::/example.org/ag1"
        # expect(proxies).not_to include "http::/example.org/ag2"
        # expect(proxies).to include "http::/example.org/ag3"
        # expect(proxies.size).to eq 1
      end

      it "should find proxies by criteria (aka proxy_for)" do
        proxies = LD4L::OreRDF::FindProxies.call(
            :aggregation => 'http::/example.org/ag2',
            :criteria => { RDFVocabularies::ORE.proxyFor => "http://example.org/individual/b22" } )
        expect(proxies.size).to eq 1
        expect(proxies.first).to be_a_kind_of RDF::URI
        pr = LD4L::OreRDF::ProxyResource.new(proxies.first)
        expect(pr.proxy_for.first).to eq "http://example.org/individual/b22"
        expect(pr.proxy_in.first.rdf_subject).to eq RDF::URI("http::/example.org/ag2")
      end

      it "should find all proxies for aggregation" do
        proxies = LD4L::OreRDF::FindProxies.call(
            :aggregation => 'http::/example.org/ag3' )
        expect(proxies.size).to eq 3
        proxy_for = []
        proxies.each do |p|
          expect(p).to be_a_kind_of RDF::URI
          pr = LD4L::OreRDF::ProxyResource.new(p)
          proxy_for << pr.proxy_for.first
          expect(pr.proxy_in.first.rdf_subject).to eq RDF::URI("http::/example.org/ag3")
        end
        expect(proxy_for).to include "http://example.org/individual/b31"
        expect(proxy_for).to include "http://example.org/individual/b32"
        expect(proxy_for).to include "http://example.org/individual/b33"
      end

    end

  end
end
