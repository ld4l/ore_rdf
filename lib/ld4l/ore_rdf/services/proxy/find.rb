module LD4L
  module OreRDF
    class FindProxies

      ##
      # Find proxies matching the specified criteria.
      #
      # @param [Hash] options the options to use to find proxies
      # @option options [String, RDF::URI, LD4L::OreRDF::AggregationResource] :aggregation - limit proxies found to this aggregation (required)
      # @option options [Hash<Object,Object>] :criteria for finding proxies (ex. RDF::DC.proxy_in=>RDF::URI('http://example.org/ag123')) (default - nil for all proxies in the aggregation)
      # @option options [Hash<Symbol><Object>] :properties to return with the proxy uri (ex. :proxy_for=>RDFVocabularies::ORE.proxyFor) (default - nil aggregation uri only)
      # @option options [Symbol] :repository to search (default - :default)
      # @option options [TrueClass,FalseClass] :resume if true, find and resume; otherwise, find only (default - false)
      #
      # @returns [Array<RDF::URI>,Hash<RDF::URI,LD4L::OreRDF::Proxy,Hash<RDF::URI,Hash<Object,Object>]
      #    if resume==false, returns URIs of matching proxy resources + specified properties' values;
      #    otherwise, returns resumed instances of matching proxies
      #
      # @example Search for all proxies in aggregation
      #   all_proxies = LD4L::OreRDF.FindProxies('http://example.org/aggregations/ag123')
      #
      # @example Search for all proxies in aggregation
      #   all_proxies = LD4L::OreRDF.FindProxies(RDF::URI('http://example.org/aggregations/ag123'))
      #
      # @example Search for all proxies in aggregation
      #   aggregation_resource = LD4L::OreRDF::AggregationResource.new('http://example.org/aggregations/ag123'))
      #   all_proxies = LD4L::OreRDF.FindProxies(aggregation_resource)
      #
      def self.call( options={} )
        aggregation = options[:aggregation] || nil
        raise ArgumentError, 'aggregation must be one of string uri, RDF::URI, LD4L::OreRDF::AggregationResource' unless
            !aggregation.nil? && ( aggregation.kind_of?(String) ||
                                   aggregation.kind_of?(RDF::URI) ||
                                   aggregation.kind_of?(LD4L::OreRDF::AggregationResource) )
        aggregation = RDF::URI(aggregation)        if aggregation.kind_of?(String)
        aggregation = aggregation.rdf_subject      if aggregation.kind_of?(LD4L::OreRDF::AggregationResource)
        # aggregation = aggregation.to_s if aggregation.kind_of?(RDF::URI)
        # aggregation = aggregation.rdf_subject.to_s if aggregation.kind_of?(LD4L::OreRDF::AggregationResource)

        repository = options[:repository] || :default
        raise ArgumentError, 'repository must be a symbol' unless repository.kind_of?(Symbol)
        raise ArgumentError, 'repository must be a registered repository' unless
            ActiveTriples::Repositories.repositories.has_key?(repository)

        resume = options[:resume] || false
        raise ArgumentError, 'resume must be true or false' unless
            resume.kind_of?(TrueClass) || resume.kind_of?(FalseClass)

        criteria = options[:criteria] || nil
        raise ArgumentError, 'criteria must be a hash of attribute-value pairs for searching for proxies'  unless
            criteria.nil? || criteria.kind_of?(Hash)
        criteria = criteria ? criteria.dup : {}
        criteria[RDF.type] = RDFVocabularies::ORE.Proxy
        criteria[RDFVocabularies::ORE.proxyIn] = aggregation

        # properties are ignored when resume==true because all properties are returned as part of the resumed proxies
        properties = options[:properties] || nil
        raise ArgumentError, 'properties must be an array of predicates'  unless
            properties.nil? || properties.kind_of?(Hash) || resume
        properties.each_key { |k| criteria[properties[k]] = k unless criteria.has_key?(properties[k]) }  unless
            properties.nil? || resume
        process_properties = properties.nil? || resume ? false : true


        graph = ActiveTriples::Repositories.repositories[repository]
        query = RDF::Query.new({ :proxy => criteria })

        process_properties || resume ? proxies = {} : proxies = []
        results = query.execute(graph)
        results.each do |r|
          h = r.to_hash
          uri = h[:proxy]
          if resume
            # if resume, return Hash of proxy uri => resumed proxy for each found
            if aggregation.respond_to? 'persistence_strategy'  # >= ActiveTriples 0.8
              proxies[uri] = LD4L::OreRDF::ProxyResource.new(uri,aggregation.list_info)
            else # < ActiveTriples 0.8
              proxies[uri] = LD4L::OreRDF::ProxyResource.new(uri)
            end
          elsif process_properties
            # if properties, return Hash of proxy uri => Hash of property => value for each found
            properties = h
            properties.delete(:proxy)
            proxies[uri] = properties
          else
            # if no properties && not resumed, return array of proxy uris
            proxies << uri
          end
        end

        proxies
      end

    end
  end
end

