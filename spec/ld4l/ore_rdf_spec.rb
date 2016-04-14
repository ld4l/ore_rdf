require "spec_helper"

describe "LD4L::OreRDF" do
  after(:all) do
    ActiveTriples::RDFSource.type_registry.keys.each { |k| ActiveTriples::RDFSource.type_registry.delete(k) } if Object.const_defined?("ActiveTriples::RDFSource")
  end

  describe "#configure" do

    before do
      LD4L::OreRDF.configure do |config|
        config.base_uri = "http://localhost/test/"
        config.localname_minter = lambda { |prefix=""| prefix+'_configured_'+SecureRandom.uuid }
      end
      class DummyAggregation < LD4L::OreRDF::AggregationResource
        configure :type => RDFVocabularies::ORE.Aggregation, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default
      end
    end
    after do
      LD4L::OreRDF.reset
      Object.send(:remove_const, "DummyAggregation") if Object
    end

    it "should return configured value" do
      config = LD4L::OreRDF.configuration
      expect(config.base_uri).to eq "http://localhost/test/"
      expect(config.localname_minter).to be_kind_of Proc
    end

    it "should use configured value in Person sub-class" do
      p = DummyAggregation.new('1')
      expect(p.rdf_subject.to_s).to eq "http://localhost/test/1"

      oa = DummyAggregation.new(ActiveTriples::LocalName::Minter.generate_local_name(
                 LD4L::OreRDF::AggregationResource, 10, 'foo',
                 &LD4L::OreRDF.configuration.localname_minter ))
      expect(oa.rdf_subject.to_s.size).to eq 73
      expect(oa.rdf_subject.to_s).to match /http:\/\/localhost\/test\/foo_configured_[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}/
    end
  end

  describe ".reset" do
    before :each do
      LD4L::OreRDF.configure do |config|
        config.base_uri = "http://localhost/test/"
        config.localname_minter = lambda { |prefix=""| prefix+'_configured_'+SecureRandom.uuid }
      end
    end

    it "resets the configuration" do
      LD4L::OreRDF.reset
      config = LD4L::OreRDF.configuration
      expect(config.base_uri).to eq "http://localhost/"
      expect(config.localname_minter).to eq nil
    end
  end
end