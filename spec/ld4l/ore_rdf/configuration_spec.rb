require 'spec_helper'

describe 'LD4L::OreRDF' do

  describe '#configuration' do
    after(:all) do
      ActiveTriples::RDFSource.type_registry.keys.each { |k| ActiveTriples::RDFSource.type_registry.delete(k) } if Object::ActiveTriples.const_defined?("RDFSource")
    end

    describe "base_uri" do
      context "when base_uri is not configured" do
        before do
          class DummyAggregation < LD4L::OreRDF::AggregationResource
            configure :type => RDF::Vocab::ORE.Aggregation, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default
          end
        end
        after do
          Object.send(:remove_const, "DummyAggregation") if Object
        end
        it "should generate an Aggregation URI using the default base_uri" do
          expect(DummyAggregation.new('1').rdf_subject.to_s).to eq "http://localhost/1"
        end
      end

      context "when uri ends with slash" do
        before do
          LD4L::OreRDF.configure do |config|
            config.base_uri = "http://localhost/test_slash/"
          end
          class DummyAggregation < LD4L::OreRDF::AggregationResource
            configure :type => RDF::Vocab::ORE.Aggregation, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default
          end
        end
        after do
          Object.send(:remove_const, "DummyAggregation") if Object
          LD4L::OreRDF.reset
        end

        it "should generate an Aggregation URI using the configured base_uri" do
          expect(DummyAggregation.new('1').rdf_subject.to_s).to eq "http://localhost/test_slash/1"
        end
      end

      context "when uri does not end with slash" do
        before do
          LD4L::OreRDF.configure do |config|
            config.base_uri = "http://localhost/test_no_slash"
          end
          class DummyAggregation < LD4L::OreRDF::AggregationResource
            configure :type => RDF::Vocab::ORE.Aggregation, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default
          end
        end
        after do
          Object.send(:remove_const, "DummyAggregation") if Object
          LD4L::OreRDF.reset
        end

        it "should generate an Aggregation URI using the configured base_uri" do
          expect(DummyAggregation.new('1').rdf_subject.to_s).to eq "http://localhost/test_no_slash/1"
        end
      end

      it "should return value of configured base_uri" do
        LD4L::OreRDF.configure do |config|
          config.base_uri = "http://localhost/test_config/"
        end
        expect(LD4L::OreRDF.configuration.base_uri).to eq "http://localhost/test_config/"
      end

      it "should return default base_uri when base_uri is reset" do
        LD4L::OreRDF.configure do |config|
          config.base_uri = "http://localhost/test_config/"
        end
        expect(LD4L::OreRDF.configuration.base_uri).to eq "http://localhost/test_config/"
        LD4L::OreRDF.configuration.reset_base_uri
        expect(LD4L::OreRDF.configuration.base_uri).to eq "http://localhost/"
      end

      it "should return default base_uri when all configs are reset" do
        LD4L::OreRDF.configure do |config|
          config.base_uri = "http://localhost/test_config/"
        end
        expect(LD4L::OreRDF.configuration.base_uri).to eq "http://localhost/test_config/"
        LD4L::OreRDF.reset
        expect(LD4L::OreRDF.configuration.base_uri).to eq "http://localhost/"
      end
    end

    describe "localname_minter" do
      context "when minter is nil" do
        before do
          class DummyAggregation < LD4L::OreRDF::AggregationResource
            configure :type => RDF::Vocab::ORE.Aggregation, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default
          end
        end
        after do
          Object.send(:remove_const, "DummyAggregation") if Object
        end
        it "should use default minter in minter gem" do
          localname = ActiveTriples::LocalName::Minter.generate_local_name(
                  LD4L::OreRDF::AggregationResource, 10, {:prefix=>'default_'},
                  LD4L::OreRDF.configuration.localname_minter )
          expect(localname).to be_kind_of String
          expect(localname.size).to eq 44
          expect(localname).to match /default_[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}/
        end
      end

      context "when minter is configured" do
        before do
          LD4L::OreRDF.configure do |config|
            config.localname_minter = lambda { |prefix=""| prefix+'_configured_'+SecureRandom.uuid }
          end
          class DummyAggregation < LD4L::OreRDF::AggregationResource
            configure :type => RDF::Vocab::ORE.Aggregation, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default
          end
        end
        after do
          Object.send(:remove_const, "DummyAggregation") if Object
          LD4L::OreRDF.reset
        end

        it "should generate an Aggregation URI using the configured localname_minter" do
          localname = ActiveTriples::LocalName::Minter.generate_local_name(
              LD4L::OreRDF::AggregationResource, 10,
              LD4L::OreRDF::AggregationResource.localname_prefix,
              &LD4L::OreRDF.configuration.localname_minter )
          expect(localname).to be_kind_of String
          expect(localname.size).to eq 50
          expect(localname).to match /ag_configured_[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}/
        end
      end
    end
  end


  describe "LD4L::OreRDF::Configuration" do
    describe "#base_uri" do
      it "should default to localhost" do
        expect(LD4L::OreRDF::Configuration.new.base_uri).to eq "http://localhost/"
      end

      it "should be settable" do
        config = LD4L::OreRDF::Configuration.new
        config.base_uri = "http://localhost/test"
        expect(config.base_uri).to eq "http://localhost/test"
      end

      it "should be re-settable" do
        config = LD4L::OreRDF::Configuration.new
        config.base_uri = "http://localhost/test/again"
        expect(config.base_uri).to eq "http://localhost/test/again"
        config.reset_base_uri
        expect(config.base_uri).to eq "http://localhost/"
      end
    end

    describe "#localname_minter" do
      it "should default to nil" do
        expect(LD4L::OreRDF::Configuration.new.localname_minter).to eq nil
      end

      it "should be settable" do
        config = LD4L::OreRDF::Configuration.new
        config.localname_minter = lambda { |prefix=""| prefix+'_configured_'+SecureRandom.uuid }
        expect(config.localname_minter).to be_kind_of Proc
      end

      it "should be re-settable" do
        config = LD4L::OreRDF::Configuration.new
        config.localname_minter = lambda { |prefix=""| prefix+'_configured_'+SecureRandom.uuid }
        expect(config.localname_minter).to be_kind_of Proc
        config.reset_localname_minter
        expect(config.localname_minter).to eq nil
      end
    end
  end
end
