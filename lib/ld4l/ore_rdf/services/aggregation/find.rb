module LD4L
  module OreRDF
    class FindAggregations

      ##
      # Find aggregations matching the specified criteria.
      #
      # @param [Hash] options the options to use to find aggregations
      # @option options [Hash<Object,Object>] :criteria for finding aggregations (ex. RDF::DC.title=>'My Aggregation') (default - nil for all aggregations)
      # @option options [Hash<Symbol><Object>] :properties to return with the aggregation uri (ex. :first_proxy=>RDFVocabularies::IANA.first) (default - nil aggregation uri only)
      # @option options [Symbol] :repository to search (default - :default)
      # @option options [TrueClass,FalseClass] :resume if true, find and resume; otherwise, find only (default - false)
      #
      # @returns [Array<RDF::URI>,Hash<RDF::URI,LD4L::OreRDF::Aggregation,Hash<RDF::URI,Hash<Object,Object>]
      #    if resume==false, returns URIs of matching aggregation resources + specified properties' values;
      #    otherwise, returns resumed instances of matching aggregations and their proxies
      #
      # @example Search for all aggregations
      #   all_aggs = LD4L::OreRDF.FindAggregations
      def self.call( options={} )
        repository = options[:repository] || :default
        raise ArgumentError, "repository (#{repository}) is not a symbol" unless repository.kind_of?(Symbol)
        raise ArgumentError, "repository (#{repository}) is not a registered repository" unless
            ActiveTriples::Repositories.repositories.has_key?(repository)

        resume = options[:resume] || false
        raise ArgumentError, 'resume must be true or false' unless
            resume.kind_of?(TrueClass) || resume.kind_of?(FalseClass)

        criteria = options[:criteria] || nil
        raise ArgumentError, 'criteria must be a hash of attribute-value pairs for searching for aggregations'  unless
            criteria.nil? || criteria.kind_of?(Hash)
        criteria = criteria ? criteria.dup : {}
        criteria[RDF.type] = RDFVocabularies::ORE.Aggregation

        # properties are ignored when resume==true because all properties are returned as part of the resumed aggregations
        properties = options[:properties] || nil
        raise ArgumentError, 'properties must be an array of predicates'  unless
            properties.nil? || properties.kind_of?(Hash) || resume
        properties.each_key { |k| criteria[properties[k]] = k unless criteria.has_key?(properties[k]) }  unless
            properties.nil? || resume
        process_properties = properties.nil? || resume ? false : true

        graph = ActiveTriples::Repositories.repositories[repository]
        query = RDF::Query.new({ :aggregation => criteria })

        process_properties || resume ? aggregations = {} : aggregations = []
        results = query.execute(graph)
        results.each do |r|
          h = r.to_hash
          uri = h[:aggregation]
          if resume
            # if resume, return Hash of aggregation uri => resumed aggregation for each found
            aggregations[uri] = LD4L::OreRDF::ResumeAggregation.call(uri)
          elsif process_properties
            # if properties, return Hash of aggregation uri => Hash of property => value for each found
            properties = h
            properties.delete(:aggregation)
            aggregations[uri] = properties
          else
            # if no properties && not resumed, return array of aggregation uris
            aggregations << uri
          end
        end

        aggregations
      end

    end
  end
end

