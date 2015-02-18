module LD4L
  module OreRDF
    class AddAggregatedResources

      ##
      # Adds each resource in the resource_array to the list of aggregated resources for the aggregation beginning at
      # the specified position or appends to the end if position is not specified.  Creates a proxy object for each
      # resource.
      #
      # @param [LD4L::OreRDF::Aggregation] :aggregation to which to add resource
      # @param [Array<RDF::URI>] resources - array of URIs for the resources to be aggregated
      # @param [insert_position] :position from beginning of the list of proxies when positive; position from the
      #    end of the list of proxies when negative
      #
      # @returns [Array<LD4L::OreRDF::ProxyResource>] the proxies created for the resources
      def self.call(aggregation,resources,insert_position=nil)
        proxy_array = []
        resources.each do |resource_uri|
          # TODO should insert_position be different with each iteration; otherwise, won't they go in backwards???
          proxy_array << LD4L::OreRDF::AddAggregatedResource.call(aggregation,resource_uri,insert_position)
        end
        proxy_array
      end

    end
  end
end

