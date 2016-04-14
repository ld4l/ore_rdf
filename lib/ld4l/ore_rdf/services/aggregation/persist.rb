module LD4L
  module OreRDF
    class PersistAggregation

      ##
      # Persist the aggregation and all associated proxies.
      #
      # @param [LD4L::OreRDF::Aggregation] aggregation to be persisted
      #
      # @returns [TrueClass,Hash]
      #     true if aggregation resource and all proxy resources were persisted; otherwise,
      #     returns Hash with
      #       :aggregation_resource_persisted is true if aggregation_resource successfully persisted; otherwise, false
      #       :percent_proxies_persisted is % of proxies successfully persisted
      def self.call( aggregation )
        raise ArgumentError, 'aggregation must be an LD4L::OreRDF::Aggregation'  unless
            aggregation && aggregation.kind_of?(LD4L::OreRDF::Aggregation)

        # TODO Probably shouldn't be ArgumentError
        raise ArgumentError, "title is required" unless
            aggregation.title && aggregation.title.kind_of?(String) && aggregation.title.size > 0

        count = 0
        agg_persisted = aggregation.aggregation_resource.persist!
        aggregation.proxy_resources.each { |proxy| count += 1 if proxy.persist! }  if agg_persisted
        percent_proxies = aggregation.proxy_resources.size > 0 ? count/aggregation.proxy_resources.size : 1
        all_persisted = agg_persisted && (percent_proxies == 1)
        ret = all_persisted ? all_persisted :
                              {
                                :aggregation_resource_persisted => agg_persisted,
                                :percent_proxies_persisted => percent_proxies
                              }
        ret
      end
    end
  end
end
