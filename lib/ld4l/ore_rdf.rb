require 'rdf'
require 'active_triples'
require 'active_triples/local_name'
require 'active_triples/solrizer'
require	'linkeddata'
require 'doubly_linked_list'
require 'ld4l/foaf_rdf'
require 'ld4l/ore_rdf/version'
require 'ld4l/ore_rdf/vocab/ore'
require 'ld4l/ore_rdf/vocab/iana'
require 'ld4l/ore_rdf/vocab/dcterms'

module LD4L
  module OreRDF

    # Methods for configuring the GEM
    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      @configuration = Configuration.new
    end

    def self.configure
      yield(configuration)
    end


    # RDF vocabularies
    autoload :DCTERMS,                'ld4l/ore_rdf/vocab/dcterms'
    autoload :IANA,                   'ld4l/ore_rdf/vocab/iana'
    autoload :ORE,                    'ld4l/ore_rdf/vocab/ore'


    # autoload classes
    autoload :Configuration,          'ld4l/ore_rdf/configuration'

    # autoload model classes
    autoload :Aggregation,            'ld4l/ore_rdf/models/aggregation'
    autoload :AggregationResource,    'ld4l/ore_rdf/models/aggregation_resource'
    autoload :ProxyResource,          'ld4l/ore_rdf/models/proxy_resource'

    # autoload service classes
    autoload :CreateAggregation,      'ld4l/ore_rdf/services/aggregation/create'
    autoload :PersistAggregation,     'ld4l/ore_rdf/services/aggregation/persist'
    autoload :ResumeAggregation,      'ld4l/ore_rdf/services/aggregation/resume'
    autoload :LoadAggregationFromSolr,'ld4l/ore_rdf/services/aggregation/load_from_solr'
    autoload :DestroyAggregation,     'ld4l/ore_rdf/services/aggregation/destroy'
    autoload :FindAggregations,       'ld4l/ore_rdf/services/aggregation/find'
    autoload :AddAggregatedResource,  'ld4l/ore_rdf/services/aggregation/add_aggregated_resource'
    autoload :AddAggregatedResources, 'ld4l/ore_rdf/services/aggregation/add_aggregated_resources'

    autoload :CreateProxy,            'ld4l/ore_rdf/services/proxy/create'
    autoload :FindProxies,            'ld4l/ore_rdf/services/proxy/find'
  end
end

