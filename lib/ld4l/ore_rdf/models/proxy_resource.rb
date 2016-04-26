module LD4L
  module OreRDF
    class ProxyResource < ActiveTriples::Resource

      class << self; attr_reader :localname_prefix end
      @localname_prefix="px"

      # configure :base_uri => LD4L::OreRDF.configuration.base_uri, repository => :default
      configure :type => RDFVocabularies::ORE.Proxy, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default

      property :proxy_for_,   :predicate => RDFVocabularies::ORE.proxyFor,  :cast => false
      property :proxy_in_,    :predicate => RDFVocabularies::ORE.proxyIn,   :class_name => LD4L::OreRDF::AggregationResource
      property :next_proxy_,  :predicate => RDFVocabularies::IANA.next,     :class_name => LD4L::OreRDF::ProxyResource
      property :prev_proxy_,  :predicate => RDFVocabularies::IANA.prev,     :class_name => LD4L::OreRDF::ProxyResource
      property :contributor,  :predicate => RDF::DC.contributor,            :class_name => LD4L::FoafRDF::Person   # TODO User who added this item to the Aggregation (default=Aggregation's owner)


      def proxy_for= value
        value = [] if value.nil?
        self.proxy_for_ = value
      end

      def proxy_for
        OreRDF::Aggregation.get_first_value self, proxy_for_
      end

      def proxy_for_subject
        OreRDF::Aggregation.get_first_value self, proxy_for_, true
      end

      def proxy_in= value
        value = [] if value.nil?
        self.proxy_in_ = value
      end

      def proxy_in
        OreRDF::Aggregation.get_first_value self, proxy_in_
      end

      def proxy_in_subject
        OreRDF::Aggregation.get_first_value self, proxy_in_, true
      end

      def next_proxy= value
        self.next_proxy_ = value
        value = [] if value.nil?
      end

      def next_proxy
        OreRDF::Aggregation.get_first_value self, next_proxy_
      end

      def next_proxy_subject
        OreRDF::Aggregation.get_first_value self, next_proxy_, true
      end

      def prev_proxy= value
        value = [] if value.nil?
        self.prev_proxy_ = value
      end

      def prev_proxy
        OreRDF::Aggregation.get_first_value self, prev_proxy_
      end

      def prev_proxy_subject
        OreRDF::Aggregation.get_first_value self, prev_proxy_, true
      end


      # --------------------- #
      #    HELPER METHODS     #
      # --------------------- #


      ########### NEED TO MOVE TO SERVICE OBJECT ####################


      # Returns an array of the LD4L::OreRDF::ProxyResource instances for the items in the aggregation
      # TODO: How to begin at start and limit to number of returned items, effectively handling ranges of data.
      def self.get_range( aggregation, start=0, limit=nil )
        # TODO: Stubbed to return all items.  Need to implement start and limit features.

        raise ArgumentError, 'aggregation must be Aggregation or AggregationResource'  unless
            aggregation.kind_of?(LD4L::OreRDF::Aggregation) || aggregation.kind_of?(LD4L::OreRDF::AggregationResource)

        aggregation_resource = aggregation
        aggregation_resource = aggregation.list_info if aggregation.kind_of?(LD4L::OreRDF::Aggregation)

        graph = ActiveTriples::Repositories.repositories[repository]
        query = RDF::Query.new({
                                 :proxy => {
                                   RDF.type =>  RDFVocabularies::ORE.Proxy,
                                   RDFVocabularies::ORE.proxyIn => aggregation_resource,
                                 }
                               })

        proxies = []
        results = query.execute(graph)
        results.each do |r|
          proxy_uri = r.to_hash[:proxy]
          if aggregation_resource.respond_to? 'persistence_strategy'  # >= ActiveTriples 0.8
            proxy = LD4L::OreRDF::ProxyResource.new(proxy_uri,aggregation_resource)
          else # < ActiveTriples 0.8
            proxy = LD4L::OreRDF::ProxyResource.new(proxy_uri)
          end
          proxies << proxy
        end
        proxies
      end
    end
  end
end