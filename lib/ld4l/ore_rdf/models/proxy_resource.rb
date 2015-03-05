module LD4L
  module OreRDF
    class ProxyResource < ActiveTriples::Resource

      class << self; attr_reader :localname_prefix end
      @localname_prefix="px"

      # configure :base_uri => LD4L::OreRDF.configuration.base_uri, repository => :default
      configure :type => RDFVocabularies::ORE.Proxy, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default

      property :proxy_for,     :predicate => RDFVocabularies::ORE.proxyFor,  :cast => false
      property :proxy_in,      :predicate => RDFVocabularies::ORE.proxyIn,   :class_name => LD4L::OreRDF::AggregationResource
      property :next_proxy,    :predicate => RDFVocabularies::IANA.next,     :class_name => LD4L::OreRDF::ProxyResource
      property :prev_proxy,    :predicate => RDFVocabularies::IANA.prev,     :class_name => LD4L::OreRDF::ProxyResource
      property :contributor,   :predicate => RDF::DC.contributor,            :class_name => LD4L::FoafRDF::Person   # TODO User who added this item to the Aggregation (default=Aggregation's owner)


      # --------------------- #
      #    HELPER METHODS     #
      # --------------------- #


      ########### NEED TO MOVE TO SERVICE OBJECT ####################


      # Returns an array of the LD4L::OreRDF::ProxyResource instances for the items in the aggregation
      # TODO: How to begin at start and limit to number of returned items, effectively handling ranges of data.
      def self.get_range( aggregation, start=0, limit=nil )
        # TODO: Stubbed to return all items.  Need to implement start and limit features.

        # argument validation
        # raise ArgumentError, 'Argument must be a string with at least one character'  unless
        #     tag_value.kind_of?(String) && tag_value.size > 0

        graph = ActiveTriples::Repositories.repositories[repository]
        query = RDF::Query.new({
                                 :proxy => {
                                   RDF.type =>  RDFVocabularies::ORE.Proxy,
                                   RDFVocabularies::ORE.proxyIn => aggregation,
                                 }
                               })

        proxies = []
        results = query.execute(graph)
        results.each do |r|
          proxy_uri = r.to_hash[:proxy]
          proxy = LD4L::OreRDF::ProxyResource.new(proxy_uri)
          proxies << proxy
        end
        proxies
      end
    end
  end
end