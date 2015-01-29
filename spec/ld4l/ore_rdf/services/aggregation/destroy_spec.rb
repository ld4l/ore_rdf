require 'spec_helper'

describe 'LD4L::OreRDF::DestroyAggregation' do

  describe "#call" do

    context "when aggregation hasn't been persisted" do
      before do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end
      after do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end

      it "should return true if never persisted" do
        id = "http::/example.org/NOT_PERSISTED"
        aggregation = LD4L::OreRDF::CreateAggregation.call(
            id:          id,
            title:       "Unpersisted Aggregation",
            description: "Test aggregation that isn't persisted." )
        expect( LD4L::OreRDF::DestroyAggregation.call(aggregation) ).to be true
        expect( LD4L::OreRDF::ResumeAggregation.call(id) ).to be nil
      end

    end

    context "when aggregation doesn't have proxies" do
      before do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
        @id = "http::/example.org/NO_PROXIES"
        @aggregation = LD4L::OreRDF::CreateAggregation.call(
            id:          @id,
            title:       "No Proxy Aggregation",
            description: "Test aggregation with no proxies." )
        LD4L::OreRDF::PersistAggregation.call(@aggregation)
        expect( LD4L::OreRDF::ResumeAggregation.call(@id).rdf_subject.to_s ).to eq @id
      end
      after do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end

      it "should destroy aggregation resource and return true" do
        expect( LD4L::OreRDF::DestroyAggregation.call(@aggregation) ).to be true
        expect( LD4L::OreRDF::ResumeAggregation.call(@id) ).to eq nil
      end
    end

    context "when aggregation has proxies" do
      before do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
        @id1 = "http::/example.org/ag1"
        @ag1 = LD4L::OreRDF::CreateAggregation.call(
            id:          @id1,
            title:       "Aggregation 1",
            description: "Test aggregation with proxies." )
        LD4L::OreRDF::AddAggregatedResources.call(
            @ag1,
            [RDF::URI("http://example.org/individual/b11"),
             RDF::URI("http://example.org/individual/b12"),
             RDF::URI("http://example.org/individual/b13")])
        LD4L::OreRDF::PersistAggregation.call(@ag1)
        a1 = LD4L::OreRDF::ResumeAggregation.call(@id1)
        expect( a1.aggregation_resource.rdf_subject.to_s ).to eq @id1
        expect( a1.proxy_resources.length).to eq 3

        @id2 = "http::/example.org/ag2"
        @ag2 = LD4L::OreRDF::CreateAggregation.call(
            id:          @id2,
            title:       "Aggregation 2",
            description: "Test description of aggregation 2.",
            owner:       p )
        LD4L::OreRDF::AddAggregatedResources.call(
            @ag2,
            [RDF::URI("http://example.org/individual/b21"),
             RDF::URI("http://example.org/individual/b22"),
             RDF::URI("http://example.org/individual/b23")])
        LD4L::OreRDF::PersistAggregation.call(@ag2)
        a2 = LD4L::OreRDF::ResumeAggregation.call(@id2)
        expect( a2.aggregation_resource.rdf_subject.to_s ).to eq @id2
        expect( a2.proxy_resources.length).to eq 3

        @id3 = "http::/example.org/ag3"
        @ag3 = LD4L::OreRDF::CreateAggregation.call(
            id:          @id3,
            title:       "Aggregation 3",
            description: "Test description of aggregation 3.",
            owner:       p )
        LD4L::OreRDF::PersistAggregation.call(@ag3)
        a3 = LD4L::OreRDF::ResumeAggregation.call(@id3)
        expect( a3.aggregation_resource.rdf_subject.to_s ).to eq @id3
        expect( a3.proxy_resources.length).to eq 0
      end
      after do
        ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      end

      context "and all parts are persisted" do
        it "should destroy aggregation resource and all proxy resources and return true" do
          expect( LD4L::OreRDF::DestroyAggregation.call(@ag1) ).to be true
          expect( LD4L::OreRDF::ResumeAggregation.call(@id1) ).to eq nil

          # verify other objects are unchanged
          ag2 = LD4L::OreRDF::ResumeAggregation.call(@id2)
          expect( ag2.rdf_subject.to_s ).to eq @id2
          expect( ag2.proxy_resources.length).to eq 3

          ag3 = LD4L::OreRDF::ResumeAggregation.call(@id3)
          expect( ag3.rdf_subject.to_s ).to eq @id3
          expect( ag3.proxy_resources.length).to eq 0
        end
      end

      context "and some proxies are persisted" do
        it "should destroy aggregation resource and persisted proxy resources and return true" do
          LD4L::OreRDF::AddAggregatedResources.call(
              @ag2,
              [RDF::URI("http://example.org/individual/b24"),
               RDF::URI("http://example.org/individual/b25")])
          expect( @ag2.rdf_subject.to_s ).to eq @id2
          expect( @ag2.proxy_resources.length).to eq 5

          expect( LD4L::OreRDF::DestroyAggregation.call(@ag2) ).to be true
          expect( LD4L::OreRDF::ResumeAggregation.call(@id2) ).to eq nil

          # verify other objects are unchanged
          ag1 = LD4L::OreRDF::ResumeAggregation.call(@id1)
          expect( ag1.rdf_subject.to_s ).to eq @id1
          expect( ag1.proxy_resources.length).to eq 3

          ag3 = LD4L::OreRDF::ResumeAggregation.call(@id3)
          expect( ag3.rdf_subject.to_s ).to eq @id3
          expect( ag3.proxy_resources.length).to eq 0
        end
      end

      context "and no proxies are persisted" do
        it "should destroy aggregation resource and return true" do
          LD4L::OreRDF::AddAggregatedResources.call(
              @ag3,
              [RDF::URI("http://example.org/individual/b31"),
               RDF::URI("http://example.org/individual/b32")])
          expect( @ag3.rdf_subject.to_s ).to eq @id3
          expect( @ag3.proxy_resources.length).to eq 2

          expect( LD4L::OreRDF::DestroyAggregation.call(@ag3) ).to be true
          expect( LD4L::OreRDF::ResumeAggregation.call(@id3) ).to eq nil

          # verify other objects are unchanged
          ag1 = LD4L::OreRDF::ResumeAggregation.call(@id1)
          expect( ag1.rdf_subject.to_s ).to eq @id1
          expect( ag1.proxy_resources.length).to eq 3

          ag2 = LD4L::OreRDF::ResumeAggregation.call(@id2)
          expect( ag2.rdf_subject.to_s ).to eq @id2
          expect( ag2.proxy_resources.length).to eq 3
        end
      end
    end

    context "when invalid parameters" do
      it "should raise error if aggregation isn't LD4L::OreRDF::Aggregation" do
        expect{ LD4L::OreRDF::DestroyAggregation.call('BAD VALUE') }.to raise_error(
            ArgumentError,'aggregation must be an LD4L::OreRDF::Aggregation')
        expect{ LD4L::OreRDF::DestroyAggregation.call(nil) }.to raise_error(
            ArgumentError,'aggregation must be an LD4L::OreRDF::Aggregation')
      end
    end
  end
end
