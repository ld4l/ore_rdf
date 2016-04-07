module LD4L
  module OreRDF
    class CreateProxy

      ##
      # Create an ore proxy in one step passing in the required information.
      #
      # @param [Hash] options the options to use while generating the proxy
      # @option options [LD4L::OreRDF::Aggregation] :aggregation - abstract aggregation to which the resource is being added (required)
      # @option options [String, RDF::URI] :resource - resource uri for the resource being added to the aggregation (required)
      # @option options [String, RDF::URI] :id - uri or localname to use for the rdf_subject of the new proxy (optional)(default - mint)
      #                - full URI   - [String, RDF::URI] used as passed in
      #                - partial id - [String] uri generated from base_uri + localname_prefix + id
      #                - nil        - uri generated from base_uri + localname_prefix + minted localname
      # @option options [Integer] :insert_position - used for ordered lists to place an item at a specific location (optional)(default - appends)
      # @option options [String, LD4L::FoafRDF::Person] :contributor - person adding the resource (optional)(default - list owner)
      #
      # @returns an instance of the new proxy (not persisted)
      def self.call( options = {} )
        # validate aggregation was passed in and of correct type
        aggregation = options[:aggregation] || nil
        raise ArgumentError, "aggregation is required" if aggregation.nil?
        raise ArgumentError, "aggregation is not LD4L::OreRDF::Aggregation" unless
            aggregation.kind_of?(LD4L::OreRDF::Aggregation)

        # validate resource was passed in and of correct type
        resource = options[:resource] || nil
        raise ArgumentError, "resource is required" if resource.nil?
        raise ArgumentError, "resource must be either a string representation of an URI or an instance of RDF::URI" unless
            resource.kind_of?(String) || resource.kind_of?(RDF::URI)

        # make sure resource is a String - HANGING ERROR will occur if set as RDF::URI
        resource = resource.to_s  if  resource.kind_of?(RDF::URI)

        # mint an id if needed
        id  = options[:id] ||
            ActiveTriples::LocalName::Minter.generate_local_name(
                LD4L::OreRDF::ProxyResource, 10, { :prefix => LD4L::OreRDF::ProxyResource.localname_prefix },
                LD4L::OreRDF.configuration.localname_minter )

        # create the proxy and set properties
        if aggregation.list_info.respond_to? 'persistence_strategy'  # >= ActiveTriples 0.8
          proxy = LD4L::OreRDF::ProxyResource.new(id,aggregation.list_info)
        else # < ActiveTriples 0.8
          proxy = LD4L::OreRDF::ProxyResource.new(id)
        end
        proxy.proxy_for    = resource
        proxy.proxy_in     = aggregation.aggregation_resource
        proxy.contributor = options[:contributor] || []   # TODO default to aggregation.owner

        insert_position = options[:insert_position] || nil
        unless insert_position.nil?
          # TODO: handle inserting item into an ordered list at position specified
          # set next_proxy and prev_proxy
          # update other items that are near it
          # TODO: what happens if prev and next aren't set on the
        end

        # TODO - defaulting to appending proxy to the end
        # TODO - need to update next_proxy, prev_proxy related to ordering
        aggregation << proxy
        proxy
      end

    end
  end
end

