module LD4L
  module OreRDF
    class CreateProxy

      ##
      # Create an ore proxy in one step passing in the required information.
      #
      # @param [Hash] options the options to use while generating the proxy
      # @option options [String, RDF::URI] :id - uri or localname to use for the rdf_subject of the new proxy (optional)
      #                - full URI   - [String, RDF::URI] used as passed in
      #                - partial id - [String] uri generated from base_uri + localname_prefix + id
      #                - nil        - uri generated from base_uri + localname_prefix + minted localname
      # @option options [LD4L::OreRDF::Aggregation] :aggregation - aggregation to which the resource is being added (required)
      # @option options [String, RDF::URI] :resource - resource uri for the resource being added to the aggregation (required)
      # @option options [Integer] :insert_position - used for ordered lists to place an item at a specific location (optional)(default - appends)
      # @option options [String, LD4L::FoafRDF::Person] :contributor - person adding the resource (optional)(default - list owner)
      #
      # @returns an instance of the new proxy (not persisted)
      def self.call( options = {} )
        # validate item was passed in
        resource = options[:resource] || nil
        raise ArgumentError, "resource is required" if resource.nil?
        resource = RDF::URI(resource)  unless  resource.kind_of?(RDF::URI)

        # validate aggregation is of correct type
        aggregation = options[:aggregation] || nil
        raise ArgumentError, "aggregation is not LD4L::OreRDF::Aggregation" unless aggregation && aggregation.kind_of?(LD4L::OreRDF::Aggregation)

        id  = options[:id] ||
            ActiveTriples::LocalName::Minter.generate_local_name(
                LD4L::OreRDF::Proxy, 10, { :prefix => LD4L::OreRDF::Proxy.localname_prefix },
                LD4L::OreRDF.configuration.localname_minter )

        proxy = LD4L::OreRDF::Proxy.new(id)

        # set ORE ontology properties
        proxy.proxy_for    = resource
        proxy.proxy_in     = aggregation

        insert_position = options[:insert_position] || nil
        unless insert_position.nil?
          # TODO: handle inserting item into an ordered list at position specified
          # set nextItem, previousItem, next, and previous properties
          # update other items that are near it
          # TODO: what happens if prev and next aren't set on the
        end
        proxy.contributor = options[:contributor] || []   # TODO default to aggregation.owner

        proxy
      end

    end
  end
end

