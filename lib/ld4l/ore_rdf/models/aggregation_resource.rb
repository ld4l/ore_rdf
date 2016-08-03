module LD4L
  module OreRDF
    class AggregationResource < ActiveTriples::Resource

      class << self; attr_reader :localname_prefix end
      @localname_prefix="ag"

      # TODO... Can we change type from Set to List to go from unordered list to ordered list?
      # TODO    Should properties for ordered lists be blocked until the list is turned into an ordered list?
      # TODO    Can you go from an ordered list back to an unordered list?
      # TODO    Can you apply order to only parts of the list, or does applying order imply all items are now ordered?
      # TODO    If all items are now ordered, what is the process for going through all subitems and adding order information?


      # TODO... items are not persisted when this class is persisted because there is not connection from this class to the items
      # TODO    Either the persist! method needs to be overridden to also save the items (which would also require an items attribute to hold them)
      # TODO    OR the item property needs to be uncommented allowing the built in functionality to save them.
      # TODO    DOWNSIDE: items and aggregators could get out of sync.  Then which is right?  Could be a problem with the first option too.


      configure :type => RDF::Vocab::ORE.Aggregation, :base_uri => LD4L::OreRDF.configuration.base_uri, :repository => :default

      # extended properties for LD4L implementation
      property :title, :predicate => RDF::Vocab::DC.title do |index|
        index.data_type = :text
        index.as :indexed, :sortable
      end
      property :description, :predicate => RDF::Vocab::DC.description do |index|
        index.data_type = :text
        index.as :indexed
      end
      property :owner, :predicate => RDF::Vocab::DC.creator, :class_name => LD4L::FoafRDF::Person do |index|
        index.data_type = :string
        index.as :stored, :indexed
      end

      # properties from ORE.Aggregation
      property :aggregates, :predicate => RDF::Vocab::ORE.aggregates, :cast => false do |index|
        index.data_type = :text
        index.as :stored, :indexed, :multiValued
      end
      property :first_proxy_,  :predicate => RDF::Vocab::IANA.first,     :class_name => LD4L::OreRDF::ProxyResource
      property :last_proxy_,   :predicate => RDF::Vocab::IANA.last,      :class_name => LD4L::OreRDF::ProxyResource


      def first_proxy= value
        value = [] if value.nil?
        self.first_proxy_ = value
      end

      def first_proxy
        OreRDF::Aggregation.get_first_value self, first_proxy_
      end

      def first_proxy_subject
        OreRDF::Aggregation.get_first_value self, first_proxy_, true
      end

      def last_proxy= value
        value = [] if value.nil?
        self.last_proxy_ = value
      end

      def last_proxy
        OreRDF::Aggregation.get_first_value self, last_proxy_
      end

      def last_proxy_subject
        OreRDF::Aggregation.get_first_value self, last_proxy_, true
      end


      # --------------------- #
      #    HELPER METHODS     #
      # --------------------- #


      ########### NEED TO MOVE TO SERVICE OBJECT ####################


      # Returns an array the items in the aggregation.
      # TODO: How to begin at start and limit to number of returned items, effectively handling ranges of data.
      def get_items_content(start=nil,limit=nil)
        # TODO: Stubbed to return all items.
        get_values('aggregates')
      end

      # Returns an array of persisted LD4L::OreRDF::ProxyResource instances for the items in the`` aggregation.
      def get_items(start=nil,limit=nil)
        LD4L::OreRDF::ProxyResource.get_range(self, start, limit)
      end

      # Get the persisted LD4L::OreRDF::ProxyResource instance that holds the content
      # NOTE: Not implemented.
      def find_item_with_content(content)
        # TODO Stubbed - Requires definition and implementation
      end

      # Return the content at the specified position in an ordered collection
      def get_item_content_at(position)
        # TODO Stubbed - Required definition and implementation
      end

      # Return the LD4L::OreRDF::ProxyResource instance for the item at the specified position in an ordered collection
      def get_item_at(position)
        # TODO Stubbed - Required definition and implementation
      end

      # Determine if the content is already in the aggregation
      def has_item_content?(content)
        # TODO Stubbed - Requires definition and implementation
      end

      # Determine if an item exists at the specified position in the ordered aggregation
      def has_item_at?(position)
        # TODO Stubbed - Requires definition and implementation
      end

      # Destroy the item with the content and remove content from the aggregation
      def destroy_item_with_content(content)
        # TODO Stubbed - Requires definition and implementation
      end

      # Destroy the item at specified position and remove content from the aggregation
      def destroy_item_at(position)
        # TODO Stubbed - Requires definition and implementation
      end

      # Determine if the aggregation holds an ordered list of items
      def is_ordered?
        # TODO Stubbed to always return false until ordered lists are implemented
        return false
      end

      ##
      # Generate the solr document hash specific to a aggregation resource.
      #
      # @param [Array<LD4L::OreRDF::ProxyResource>] :all_proxies - pass in proxies instead of querying (optional)
      #
      # @returns [Hash] solr document
      #
      # NOTE: If all_proxies is [], then will try to query from triple store which means that if the proxies have not
      #       yet been persisted, then they will not be found.
      # NOTE: This method should not be called directory.  Use LD4L::OreRDF::Aggregation.generate_solr_documents instead.
      def generate_solr_document( all_proxies=[] )
        solr_doc = ActiveTriples::Solrizer::IndexingService.new(self).generate_solr_document do |solr_doc|
          # TODO add owner_name and owner sort field
          # solr_doc.merge!(:owner_name_ti => owner.name)   # TODO add name to FOAF Gem
          # solr_doc.merge!(:owner_name_sort_ss => owner.name)

          # add all item_proxies
          all_proxies = get_items if all_proxies.empty?  # NOTE: get_items depends on aggregation_resource being persisted prior to this call
          proxy_ids = all_proxies.collect { |item| item.id }
          solr_doc.merge!(self.class.item_proxies_solr_name => proxy_ids)
          solr_doc
        end
        solr_doc
     end

      def self.item_proxies_solr_name
        :item_proxies_ssm
      end
    end
  end
end
