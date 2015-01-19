module LD4L
  module OreRDF
    class PersistAggregation

      ##
      # Persist the aggregation and all associated proxies.
      #
      # @param [LD4L::OreRDF::AggregationResource] aggregation to be persisted
      #
      # @returns true if successful; otherwise, false
      def self.call( aggregation )
        # NOTE: The linked list's list_info is the aggregation_resource object
        aggregation.aggregation_resource.persist!
        aggregation.proxy_resources.each { |proxy| proxy.persist! }
      end
    end
  end
end

