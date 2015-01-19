module LD4L
  module OreRDF
    class FindAggregations

      ##
      # Find aggregations matching the specified criteria.
      #
      # @param [Hash] options the options to use to find aggregations
      # @option options [Hash<Object,Object>] :criteria for finding aggregations
      # @option options [Symbol] :repository to search
      #
      # @returns [Array<RDF::URI>] URIs of matching aggregations
      #
      # @example Search for all aggregations
      #   LD4L::OreRDF.FindAggregations
      #     config.base_uri         = "http://www.example.org/annotations/"
      #     config.localname_minter = lambda { |prefix=""| prefix+SecureRandom.uuid }
      #     config.unique_tags      = true
      #   end

      def self.call( criteria=nil, repository=:default )
        raise ArgumentError, 'Argument criteria must be a hash of attribute-value pairs for searching for aggregations'  unless
            criteria.nil? || criteria.kind_of?(Hash)
        criteria = criteria ? criteria.dup : {}

        criteria[RDF.type] = RDFVocabularies::ORE.Aggregation

        graph = ActiveTriples::Repositories.repositories[repository]
        query = RDF::Query.new({ :aggregation => criteria })

        aggregations = []
        results = query.execute(graph)
        results.each { |r| aggregations << r.to_hash[:aggregation] }
        aggregations
      end
    end
  end
end

