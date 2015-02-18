module LD4L
  module OreRDF
    class DestroyAggregationWithID

      ##
      # Destroy the aggregation and all associated proxies.
      #
      # @param [String,RDF::URI] uri of aggregation resource to destroy
      #
      # @returns [TrueClass,Hash]
      #     true if aggregation and all proxies destroyed; otherwise,
      #     returns Hash with
      #       :aggregation_resource_destroyed is true if aggregation_resource successfully destroyed; otherwise, false
      #       :percent_proxies_destroyed is % of proxies successfully destroyed
      def self.call( id )
        aggregation = LD4L::OreRDF::ResumeAggregation.call(id)
        LD4L::OreRDF::DestroyAggregation.call(aggregation)
      end
    end
  end
end

