require 'spec_helper'

describe 'LD4L::OreRDF::CreateProxy' do

   describe "#call" do
    it "should create a LD4L::OreRDF::ProxyResource instance" do
      aggregation  = LD4L::OreRDF::Aggregation.new
      proxy = LD4L::OreRDF::CreateProxy.call(
          resource:    RDF::URI("http://example.org/individual/b1"),
          aggregation: aggregation)
      expect(proxy).to be_kind_of LD4L::OreRDF::ProxyResource
    end

    context "when id is not passed in" do
      it "should generate an id with random ending" do
        aggregation  = LD4L::OreRDF::Aggregation.new
        proxy = LD4L::OreRDF::CreateProxy.call(
            resource:    RDF::URI("http://example.org/individual/b1"),
            aggregation: aggregation)
        uri = proxy.rdf_subject.to_s
        expect(uri).to start_with "#{LD4L::OreRDF::ProxyResource.base_uri}#{LD4L::OreRDF::ProxyResource.localname_prefix}"
        id = uri[uri.length-36..uri.length]
        expect(id).to be_kind_of String
        expect(id.length).to eq 36
        expect(id).to match /[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}/
      end

      it "should set property values" do
        aggregation  = LD4L::OreRDF::Aggregation.new
        proxy = LD4L::OreRDF::CreateProxy.call(
            resource:    RDF::URI("http://example.org/individual/b1"),
            aggregation: aggregation)
        expect(proxy.proxy_for.first).to eq "http://example.org/individual/b1"
        expect(proxy.proxy_in.first).to eq aggregation.aggregation_resource
        expect(proxy.next_proxy).to eq []
        expect(proxy.prev_proxy).to eq []
        # expect(proxy.contentContent.first.rdf_subject.to_s).to eq "http://example.org/individual/b1"
        # expect(proxy.index).to eq []
        # expect(proxy.nextItem).to eq []
        # expect(proxy.previousItem).to eq []
        expect(proxy.contributor).to eq []
      end
    end

    context "when partial id is passed in" do
      it "should generate an id ending with partial id" do
        aggregation  = LD4L::OreRDF::Aggregation.new
        proxy = LD4L::OreRDF::CreateProxy.call(
            id:          "123",
            resource:    RDF::URI("http://example.org/individual/b1"),
            aggregation: aggregation)
        expect(proxy.rdf_subject.to_s).to eq "#{LD4L::OreRDF::ProxyResource.base_uri}123"
      end

      it "should set property values" do
        aggregation  = LD4L::OreRDF::Aggregation.new
        proxy = LD4L::OreRDF::CreateProxy.call(
            id:          "123",
            resource:    RDF::URI("http://example.org/individual/b1"),
            aggregation: aggregation)
        expect(proxy.proxy_for.first).to eq "http://example.org/individual/b1"
        expect(proxy.proxy_in.first).to eq aggregation.aggregation_resource
        expect(proxy.next_proxy).to eq []
        expect(proxy.prev_proxy).to eq []
        # expect(proxy.contentContent.first.rdf_subject.to_s).to eq "http://example.org/individual/b1"
        # expect(proxy.index).to eq []
        # expect(proxy.nextItem).to eq []
        # expect(proxy.previousItem).to eq []
        expect(proxy.contributor).to eq []
      end
    end

    context "when URI id is passed in" do
      it "should use passed in id" do
        aggregation  = LD4L::OreRDF::Aggregation.new
        proxy = LD4L::OreRDF::CreateProxy.call(
            id:          "http://example.org/individual/ag123",
            resource:    RDF::URI("http://example.org/individual/b1"),
            aggregation: aggregation)
        expect(proxy.rdf_subject.to_s).to eq "http://example.org/individual/ag123"
      end

      it "should set property values" do
        aggregation  = LD4L::OreRDF::Aggregation.new
        proxy = LD4L::OreRDF::CreateProxy.call(
            id:          "http://example.org/individual/ag123",
            resource:    RDF::URI("http://example.org/individual/b1"),
            aggregation: aggregation)
        expect(proxy.proxy_for.first).to eq "http://example.org/individual/b1"
        expect(proxy.proxy_in.first).to eq aggregation.aggregation_resource
        expect(proxy.next_proxy).to eq []
        expect(proxy.prev_proxy).to eq []
        # expect(proxy.itemContent.first.rdf_subject.to_s).to eq "http://example.org/individual/b1"
        # expect(proxy.index).to eq []
        # expect(proxy.nextItem).to eq []
        # expect(proxy.previousItem).to eq []
        expect(proxy.contributor).to eq []
      end
    end

    context "when collection is unordered" do
      context "and insert_position is missing" do
        xit "should add item without setting ordered properties" do
          pending "this needs to be implemented"
        end
      end

      context "and insert position is passed in" do
        xit "should convert the list from unordered to ordered" do
          pending "this needs to be implemented"
        end

        xit "should set ordered properties for new item" do
          pending "this needs to be implemented"
        end

        xit "should not change any other items in the collection" do
          # TODO Is this really the behavior we want when converting from unordered to ordered?
          pending "this needs to be implemented"
        end
      end
    end

    context "when collection is ordered" do
      context "and insert_position is missing" do
        xit "should append item to the end of the collection" do
          pending "this needs to be implemented"
        end
      end

      context "and insert position is passed in" do
        xit "should set ordered properties for new item" do
          pending "this needs to be implemented"
        end

        xit "should not change any other items in the collection" do
          # TODO Is this really the behavior we want for ordered lists to be partially ordered?
          pending "this needs to be implemented"
        end
      end
    end
  end
end
