module LD4L
  module OreRDF
    class Configuration

      attr_reader :base_uri

      def self.default_base_uri
        @default_base_uri = "http://localhost/".freeze
      end
      private_class_method :default_base_uri

      def initialize
        @base_uri = self.class.send(:default_base_uri)
      end

      def base_uri=(new_base_uri)
        @base_uri = new_base_uri
      end

      def reset_base_uri
        @base_uri = self.class.send(:default_base_uri)
      end
    end
  end
end
