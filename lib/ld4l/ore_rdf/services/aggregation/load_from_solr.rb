module LD4L
  module OreRDF
    class LoadAggregationFromSolr

      ##
      # Load the aggregation and all associated proxies from the solr.
      #
      # @param [RDF::URI] uri of aggregation resource to load
      #
      # @returns
      def self.call( uri )
        raise ArgumentError, 'uri must be an RDF::URI'  unless
            uri && uri.kind_of?(RDF::URI)

binding.pry
        query = ActiveTriples::Solrizer::SolrQueryBuilder.raw_query(:id,uri.to_s)
        results = ActiveTriples::Solrizer::SolrService.query(query)
        return nil unless results.size > 0


# TODO ERROR HAPPENS HERE
        aggregation_resource = ActiveTriples::Solrizer::IndexingService.load_from_solr_document(results.first)


        proxy_resources = LD4L::OreRDF::FindProxies.call(
            :aggregation => aggregation_resource,
            :repository  => LD4L::OreRDF::ProxyResource.repository,
            :resume      => true
        )
        LD4L::OreRDF::Aggregation.new(
            :aggregation_resource => aggregation_resource,
            :proxy_resources      => proxy_resources.values)
      end
    end
  end
end

