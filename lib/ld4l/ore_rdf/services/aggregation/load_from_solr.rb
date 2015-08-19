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

        query = ActiveTriples::Solrizer::SolrQueryBuilder.id_query(uri.to_s)
        results = ActiveTriples::Solrizer::SolrService.query(query)
        return nil unless results.size > 0

        solr_doc = results.first
        aggregation_resource = ActiveTriples::Solrizer::IndexingService.load_from_solr_document(solr_doc, true)
        return nil if aggregation_resource.nil?

        proxy_resources = []
        proxy_ids = solr_doc[LD4L::OreRDF::AggregationResource.item_proxies_solr_name.to_s]
        query = ActiveTriples::Solrizer::SolrQueryBuilder.construct_query_for_ids(proxy_ids)
        results = ActiveTriples::Solrizer::SolrService.query(query)
        results.each do |solr_doc|
          proxy_resource = ActiveTriples::Solrizer::IndexingService.load_from_solr_document(solr_doc)
          proxy_resources << proxy_resource
        end

        LD4L::OreRDF::Aggregation.new(
            :aggregation_resource => aggregation_resource,
            :proxy_resources      => proxy_resources)
      end
    end
  end
end

