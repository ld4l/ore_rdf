module LD4L
  module OreRDF
    class ResumeAggregation

      ##
      # Resume the aggregation and all associated proxies.
      #
      # @param [String,RDF::URI] uri of aggregation resource to resume
      #
      # @returns
      def self.call( id )
        aggregation_resource = LD4L::OreRDF::AggregationResource.new(id)
        proxy_resources = LD4L::OreRDF::FindProxies.call(
            :aggregation => aggregation_resource,
            :repository  => LD4L::OreRDF::ProxyResource.repository,
            :resume      => true
        )
        LD4L::OreRDF::Aggregation.new(
            :aggregation_resource => aggregation_resource,
            :proxy_resources      => proxy_resources)
      end
    end
  end
end

