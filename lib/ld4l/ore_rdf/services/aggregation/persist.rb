module LD4L
  module OreRDF
    class PersistAggregation

      ##
      # Persist the aggregation and all associated proxies.
      #
      # @param [LD4L::OreRDF::AggregationResource] aggregation to be persisted
      #
      # @returns [Hash] :agg_persisted true if aggregation_resource successfully persisted
      #                 :percent_proxies is 100% if all proxies successfully persisted; otherwise, % of proxies
      #                 successfully persisted
      def self.call( aggregation )
        count = 0
        agg_persisted = aggregation.aggregation_resource.persist!
        aggregation.proxy_resources.each { |proxy| count += 1 if proxy.persist! }
        percent_proxies = aggregation.proxy_resources.size > 0 ? count/aggregation.proxy_resources.size : 1
        ret = {
                :aggregation_resource_persisted => agg_persisted,
                :percent_proxies => percent_proxies
              }
        ret
      end
    end
  end
end

