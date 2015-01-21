module LD4L
  module OreRDF
    class Aggregation < DoublyLinkedList

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

      def aggregation_resource
        list_info
      end

      def proxy_resources
        @list
      end

    end
  end
end

