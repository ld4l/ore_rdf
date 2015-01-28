require 'active_model'
module LD4L
  module OreRDF
    class Aggregation < DoublyLinkedList

      def self.initialize
        super
      end

      def initialize(*args)
        new_args = args[0].dup unless args.empty?
        unless args.empty?
          new_args[:items]     = new_args[:proxy_resources]      if new_args.is_a?(Hash) && new_args.key?(:proxies)
          new_args[:list_info] = new_args[:aggregation_resource] if new_args.is_a?(Hash) && new_args.key?(:aggregation_resource)
          new_args.delete(:proxy_resources)
          new_args.delete(:aggregation_resource)
        end
        super(new_args)
      end

      def title
        titles = list_info.title
        titles.kind_of?(Array) && titles.size > 0 ? titles[0] : ""
      end

      def description
        descriptions = list_info.description
        descriptions.kind_of?(Array) && descriptions.size > 0 ? descriptions[0] : ""
      end

      def aggregation_resource
        list_info
      end

      def proxy_resources
        @list
      end

    end
  end
end

