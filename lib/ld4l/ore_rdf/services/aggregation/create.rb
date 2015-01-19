module LD4L
  module OreRDF
    class CreateAggregation

      ##
      # Create an ore aggregation in one step passing in the required information.
      #
      # @param [Hash] options the options to use while generating the aggregation
      # @option options [String, RDF::URI] :id - uri or localname to use for the rdf_subject of the new aggregation (optional)
      #                - full URI   - [String, RDF::URI] used as passed in
      #                - partial id - [String] uri generated from base_uri + localname_prefix + id
      #                - nil        - uri generated from base_uri + localname_prefix + minted localname
      # @option options [String] :title - title of the aggregation
      # @option options [String] :description - description of the aggregation
      # @option options [String, LD4L::FoafRDF::Person] :owner - owner of the aggregation
      #
      # @returns an instance of the new aggregation (not persisted)
      def self.call( options = {} )
        id             = options[:id]          || ActiveTriples::LocalName::Minter.generate_local_name(LD4L::OreRDF::Aggregation)  # TODO pass in localname_prefix for Aggregation class
        aggregation = LD4L::OreRDF::Aggregation.new(id)
        aggregation.title       = options[:title]       || []
        aggregation.description = options[:description] || []
        aggregation.owner       = options[:owner]       || []
        aggregation
      end
    end
  end
end

