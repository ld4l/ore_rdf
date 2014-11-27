require 'rdf'
require 'active_triples'
require 'active_triples/local_name'
require	'linkeddata'
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
    autoload :DCTERMS,               'ld4l/ore_rdf/vocab/dcterms'
    autoload :IANA,                  'ld4l/ore_rdf/vocab/iana'
    autoload :ORE,                   'ld4l/ore_rdf/vocab/ore'


    # autoload classes
    autoload :Configuration,         'ld4l/ore_rdf/configuration'
    autoload :Aggregation,           'ld4l/ore_rdf/aggregation'
    autoload :Proxy,                 'ld4l/ore_rdf/proxy'

    def self.class_from_string(class_name, container_class=Kernel)
      container_class = container_class.name if container_class.is_a? Module
      container_parts = container_class.split('::')
      (container_parts + class_name.split('::')).flatten.inject(Kernel) do |mod, class_name|
        if mod == Kernel
          Object.const_get(class_name)
        elsif mod.const_defined? class_name.to_sym
          mod.const_get(class_name)
        else
          container_parts.pop
          class_from_string(class_name, container_parts.join('::'))
        end
      end
    end

  end
end

