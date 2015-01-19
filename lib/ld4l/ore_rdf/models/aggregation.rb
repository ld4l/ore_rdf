module LD4L
  module OreRDF
    class Aggregation < DoublyLinkedList

      def aggregation_resource
        list_info
      end

      def proxy_resources
        @list
      end

    end
  end
end

