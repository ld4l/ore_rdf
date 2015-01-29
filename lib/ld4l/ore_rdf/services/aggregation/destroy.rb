require 'pry'
module LD4L
  module OreRDF
    class DestroyAggregation

      ##
      # Destroy the aggregation and all associated proxies.
      #
      # @param [LD4L::OreRDF::Aggregation] aggregation to be destroyed
      #
      # @returns [TrueClass,Hash]
      #     true if aggregation resource is empty
      #     true if aggregation resource is not persisted
      #     true if aggregation resource and all proxy resources were destroyed; otherwise,
      #     returns Hash with
      #       :aggregation_resource_destroyed is true if aggregation_resource successfully destroyed; otherwise, false
      #       :percent_proxies_destroyed is % of proxies successfully destroyed
      def self.call( aggregation )
        raise ArgumentError, 'aggregation must be an LD4L::OreRDF::Aggregation'  unless
            aggregation && aggregation.kind_of?(LD4L::OreRDF::Aggregation)

        return true unless aggregation.aggregation_resource
        return true unless ActiveTriples::Resource.uri_persisted?(aggregation.aggregation_resource.rdf_subject)

        # have to get actual persisted proxy resources since the ones in the object may not have been persisted
# binding.pry
        proxy_resources = LD4L::OreRDF::FindProxies.call(
            :aggregation => aggregation.aggregation_resource,
            :repository  => LD4L::OreRDF::ProxyResource.repository,
            :resume      => true
        )

        count = 0
        total = proxy_resources.size
        proxy_resources.each { |id,proxy| count += 1 if proxy.destroy! }
        percent_proxies = total > 0 ? count/total : 1
        agg_destroyed = percent_proxies == 1 ? aggregation.aggregation_resource.destroy! : false
        all_destroyed = agg_destroyed && (percent_proxies == 1)
        ret = all_destroyed ? all_destroyed :
            {
                :aggregation_resource_destroyed => agg_destroyed,
                :percent_proxies_destroyed => percent_proxies
            }
        ret
      end
    end
  end
end

