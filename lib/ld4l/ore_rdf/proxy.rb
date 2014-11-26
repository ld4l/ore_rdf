require 'ld4l/ore_rdf/vocab/ore'
require 'ld4l/ore_rdf/vocab/iana'
require 'ld4l/foaf_rdf'
require 'rdf'

module LD4L
  module OreRDF
    class Proxy < ActiveTriples::Resource

      @id_prefix="vci"

      ORE_UNORDERED_LIST_ITEM_TYPE = RDFVocabularies::ORE.Proxy
      ORE_ORDERED_LIST_ITEM_TYPE   = RDFVocabularies::ORE.Proxy
      # CO_UNORDERED_LIST_ITEM_TYPE  = RDFVocabularies::CO.Element
      # CO_ORDERED_LIST_ITEM_TYPE    = RDFVocabularies::CO.ListItem


      # configure :base_uri => LD4L::OreRDF.configuration.base_uri, repository => :default
      configure :type => RDFVocabularies::ORE.Proxy, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default

      # common properties
      property :type,          :predicate => RDF::type             # multiple: CO.Element, CO.ListItem, ORE.Proxy
      property :contributor,   :predicate => RDF::DC.contributor,            :class_name => LD4L::FoafRDF::Person   # TODO User who added this item to the Virtual Collection (default=Virtual Collection's owner)

      # # properties from CO.Element
      # property :itemContent,   :predicate => RDFVocabularies::CO.itemContent
      #
      # # extended properties from CO.ListItem (also uses properties for CO.Element)
      # property :index,         :predicate => RDFVocabularies::CO.index                                            # TODO Maintenance of index is onerous as an insert requires touching O(N-index) items, but having an index will help with retrieving ranges of items
      # property :nextItem,      :predicate => RDFVocabularies::CO.nextItem,   :class_name => LD4L::OreRDF::Proxy
      # property :previousItem,  :predicate => RDFVocabularies::CO.nextItem,   :class_name => LD4L::OreRDF::Proxy

      # properties from ORE.Proxy
      property :proxyFor,      :predicate => RDFVocabularies::ORE.proxyFor
      property :proxyIn,       :predicate => RDFVocabularies::ORE.proxyIn,   :class_name => LD4L::OreRDF::Aggregation
      property :next,          :predicate => RDFVocabularies::IANA.next,     :class_name => LD4L::OreRDF::Proxy
      property :prev,          :predicate => RDFVocabularies::IANA.prev,     :class_name => LD4L::OreRDF::Proxy


      # --------------------- #
      #    HELPER METHODS     #
      # --------------------- #

      # Create an aggregation item in one step passing in the required information.
      #   options:
      #     id                 (optional) - used to assign RDFSubject
      #                - full URI   - used as passed in
      #                - partial id - uri generated from base_uri + id_prefix + id
      #                - nil        - uri generated from base_uri + id_prefix + random_number
      #     aggregation        (required) - aggregation to which item is being added
      #     content            (required) - content for the item being added to the collection
      #     insert_position    (optional) - used for ordered lists to place an item at a specific location (default - appends)
      #     contributor        (optional) - assumed to be list owner if not specified
      def self.create( options = {} )
        # validate item was passed in
        content = options[:content] || nil
        raise ArgumentError, "content is required" if content.nil?

        # validate aggregation is of correct type
        aggregation = options[:aggregation] || nil
        raise ArgumentError, "aggregation is not LD4L::OreRDF::Aggregation" unless aggregation.kind_of?(LD4L::OreRDF::Aggregation)

        id  = options[:id] || generate_id
        vci = LD4L::OreRDF::Proxy.new(id)

        # set ORE ontology properties
        vci.proxyFor    = content
        vci.proxyIn     = aggregation.kind_of?(String) ? RDF::URI(aggregation) : aggregation

        # # set Collections ontology properties
        # vci.itemContent = content

        # types = [ CO_UNORDERED_LIST_ITEM_TYPE, ORE_UNORDERED_LIST_ITEM_TYPE ]
        types = ORE_UNORDERED_LIST_ITEM_TYPE
        insert_position = options[:insert_position] || nil
        unless insert_position.nil?
          # TODO: handle inserting item into an ordered list at position specified
          # set nextItem, previousItem, next, and previous properties
          # update other items that are near it
          # TODO: what happens if prev and next aren't set on the
          # types = [ CO_ORDERED_LIST_ITEM_TYPE, ORE_ORDERED_LIST_ITEM_TYPE ]
          types = ORE_ORDERED_LIST_ITEM_TYPE
        end
        vci.contributor = options[:contributor] || []   # TODO default to vc.owner

        vci.type = types
        vci
      end


      # Returns an array of the LD4L::OreRDF::Proxy instances for the items in the aggregation
      # TODO: How to begin at start and limit to number of returned items, effectively handling ranges of data.
      def self.get_range( aggregation, start=0, limit=nil )
        # TODO: Stubbed to return all items.  Need to implement start and limit features.
        r = ActiveTriples::Repositories.repositories[LD4L::OreRDF::Proxy.repository]
        vci_array = []
        r.query(:predicate => RDFVocabularies::ORE.proxyIn,
                :object => aggregation.rdf_subject).statements.each do |s|
          vci = LD4L::OreRDF::Proxy.new(s.subject)
          vci_array << vci
        end
        vci_array
      end
    end
  end
end