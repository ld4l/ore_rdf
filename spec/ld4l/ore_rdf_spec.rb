require "spec_helper"

describe "LD4L::OreRDF" do
  describe "#configure" do

    before do
      LD4L::OreRDF.configure do |config|
        config.base_uri = "http://localhost/test/"
      end

      # TODO - should this be DummyPerson or is this a copy error?
      class DummyCollection < LD4L::OreRDF::Collection
        configure :type => RDFVocabularies::ORE.Aggregation, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default
      end
    end
    after do
      LD4L::OreRDF.reset
      Object.send(:remove_const, "DummyCollection") if Object
    end

    it "should return configured value" do
      config = LD4L::OreRDF.configuration
      expect(config.base_uri).to eq "http://localhost/test/"
    end

    it "should use configured value in Person sub-class" do
      p = DummyPerson.new('1')
      expect(p.rdf_subject.to_s).to eq "http://localhost/test/1"
    end
  end

  describe ".reset" do
    before :each do
      LD4L::OreRDF.configure do |config|
        config.base_uri = "http://localhost/test/"
      end
    end

    it "resets the configuration" do
      LD4L::OreRDF.reset
      config = LD4L::OreRDF.configuration
      expect(config.base_uri).to eq "http://localhost/"
    end
  end
end