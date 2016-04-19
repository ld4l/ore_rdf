require 'active_model'
module LD4L
  module OreRDF
    class Aggregation < DoublyLinkedList

      @@clear_first_callback  = lambda { |aggregation| aggregation.first_proxy = [] }
      @@clear_last_callback   = lambda { |aggregation| aggregation.last_proxy  = [] }
      @@update_first_callback = lambda { |aggregation, proxies| aggregation.first_proxy = proxies.first }
      @@update_last_callback  = lambda { |aggregation, proxies| aggregation.last_proxy  = proxies.last }

      @@clear_next_callback   = lambda { |proxies, idx| proxies[idx].next_proxy = [] }
      @@clear_prev_callback   = lambda { |proxies, idx| proxies[idx].prev_proxy = [] }
      @@update_next_callback  = lambda { |proxies, idx| proxies[idx].next_proxy = proxies[idx+1] }
      @@update_prev_callback  = lambda { |proxies, idx| proxies[idx].prev_proxy = proxies[idx-1] }

      @@find_first_callback   = lambda do |aggregation, proxies|
        first_proxy = aggregation.first_proxy
        return first_proxy.first   if first_proxy && !first_proxy.empty?

        # if first isn't set, try to figure out first by looking for an item with prev_proxy == nil
        # NOTE: If multiple items have prev_proxy == nil, it will return the first one it finds.
        first_idx = proxies.index { |proxy| proxy.prev_proxy == [] }
        first_idx ? proxies[first_idx] : nil
      end
      @@find_last_callback    = lambda do |aggregation, proxies|
        last_proxy = aggregation.last_proxy
        return last_proxy.first   if last_proxy && !last_proxy.empty?

        # if last isn't set, try to figure out last by looking for an item with next_proxy == nil
        # NOTE: If multiple items have next_proxy == nil, it will return the first one it finds.
        last_idx = proxies.index { |proxy| proxy.next_proxy == [] }
        last_idx ? proxies[last_idx] : nil
      end
      @@find_next_callback    = lambda { |proxies, current_proxy| current_proxy.next_proxy.first }
      @@find_prev_callback    = lambda { |proxies, current_proxy| current_proxy.prev_proxy.first }


      def self.initialize
        super
      end

      def initialize(*args)
        new_args = args[0].dup unless args.empty?
        unless args.empty?
          new_args[:items]     = new_args[:proxy_resources]      if new_args.is_a?(Hash) && new_args.key?(:proxy_resources)
          new_args[:list_info] = new_args[:aggregation_resource] if new_args.is_a?(Hash) && new_args.key?(:aggregation_resource)
          new_args.delete(:proxy_resources)
          new_args.delete(:aggregation_resource)
        end
        new_args = {}  if args.empty?

        # set callbacks
        new_args[:clear_first_callback]  = @@clear_first_callback
        new_args[:clear_last_callback]   = @@clear_last_callback
        new_args[:update_first_callback] = @@update_first_callback
        new_args[:update_last_callback]  = @@update_last_callback

        new_args[:clear_next_callback]   = @@clear_next_callback
        new_args[:clear_prev_callback]   = @@clear_prev_callback
        new_args[:update_next_callback]  = @@update_next_callback
        new_args[:update_prev_callback]  = @@update_prev_callback

        new_args[:find_first_callback]   = @@find_first_callback
        new_args[:find_last_callback]    = @@find_last_callback
        new_args[:find_next_callback]    = @@find_next_callback
        new_args[:find_prev_callback]    = @@find_prev_callback

        super(new_args)
      end

      def id
        list_info.rdf_subject.to_s
      end

      def title
        titles = list_info.title
        titles = titles.to_a if Object::ActiveTriples.const_defined?("Relation") && titles.kind_of?(ActiveTriples::Relation)
        titles.kind_of?(Array) && titles.size > 0 ? titles.first : ""
      end

      def description
        descriptions = list_info.description
        descriptions = descriptions.to_a if Object::ActiveTriples.const_defined?("Relation") && descriptions.kind_of?(ActiveTriples::Relation)
        descriptions.kind_of?(Array) && descriptions.size > 0 ? descriptions.first : ""
      end

      def aggregation_resource
        list_info
      end

      def proxy_resources
        @list
      end

#       def self.model_name
#         ActiveModel::Name.new(LD4L::OreRDF::Aggregation)
#       end

    end
  end
end

