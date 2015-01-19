module LD4L
  module OreRDF
    class AddAggregatedResource

      ##
      # Add a single item URI to the items for the aggregation.
      # Optionally insert the item at the passed position.  Append when position is nil.
      # NOTE: Ordered lists is currently not supported.  TODO: Implement ordered lists.
      # TODO: WARNING: This does not look like it would scale.  Getting all, adding to array, and setting all.  Very costly when there are 10s of thousands.

      ##
      # Adds a resource to the list of aggregated resources for the aggregation inserting at the specified position or
      # appends to the end if position is not specified.  Creates a proxy object for the resource.
      #
      # @param [RDF::URI] resource_uri - URI for the resources to be aggregated
      #
      # @returns [LD4L::OreRDF::Proxy] the proxy created for the resource
      def self.call(aggregation,resource_uri,insert_position=nil)
        # aggregates = get_values('aggregates')
        # aggregates << resource_uri
        # set_value('aggregates',aggregates)
        aggregates = aggregation.aggregates.dup
        aggregates << resource_uri
        aggregation.aggregates = aggregates
        LD4L::OreRDF::CreateProxy.call(
            :resource        => resource_uri,
            :aggregation     => aggregation,
            :insert_position => insert_position)
      end

    end
  end
end

