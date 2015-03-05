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
      # @param [LD4L::OreRDF::Aggregation] :aggregation to which to add resource
      # @param [String] :resource - URI for the resources to be aggregated
      # @param [insert_position] :position from beginning of the list of proxies when positive; position from the
      #    end of the list of proxies when negative
      #
      # @returns [LD4L::OreRDF::ProxyResource] the proxy created for the resource
      def self.call(aggregation,resource,insert_position=nil)
        raise ArgumentError, "resource must be either a string representation of an URI or an instance of RDF::URI" unless
            resource.kind_of?(String) || resource.kind_of?(RDF::URI)

        # make sure resource is a String - HANGING ERROR will occur if set as RDF::URI
        resource = resource.to_s         if      resource.kind_of?(RDF::URI)

        # validate aggregation is of correct type
        raise ArgumentError, "aggregation is not LD4L::OreRDF::Aggregation" unless
            aggregation.kind_of?(LD4L::OreRDF::Aggregation)


        # aggregates = get_values('aggregates')
        # aggregates << resource_uri
        # set_value('aggregates',aggregates)

        aggregates = aggregation.aggregates.dup
        aggregates << resource
        aggregation.aggregates = aggregates

        LD4L::OreRDF::CreateProxy.call(
            :resource        => resource,
            :aggregation     => aggregation,
            :insert_position => insert_position)
      end

    end
  end
end

