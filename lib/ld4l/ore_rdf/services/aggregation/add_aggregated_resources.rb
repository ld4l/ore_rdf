module LD4L
  module OreRDF
    class AddAggregatedResources

      ##
      # Adds each resource in the resource_array to the list of aggregated resources for the aggregation beginning at
      # the specified position or appends to the end if position is not specified.  Creates a proxy object for each
      # resource.
      #
      # @param [Array<RDF::URI>] resource_array - array of URIs for the resources to be aggregated
      #
      # @returns [Array<LD4L::OreRDF::Proxy>] the proxies created for the resources
      def self.call(aggregation,resource_array,insert_position=nil)
        proxy_array = []
        resource_array.each do |resource_uri|
          # TODO should insert_position be different with each iteration; otherwise, won't they go in backwards???
          proxy_array << LD4L::OreRDF::AddAggregatedResource.call(aggregation,resource_uri,insert_position)
        end
        proxy_array
      end

    end
  end
end

