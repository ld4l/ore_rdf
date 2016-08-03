#LD4L::OreRDF

[![Build Status](https://travis-ci.org/ld4l/ore_rdf.png?branch=master)](https://travis-ci.org/ld4l/ore_rdf) 
[![Coverage Status](https://coveralls.io/repos/ld4l/ore_rdf/badge.png?branch=master)](https://coveralls.io/r/ld4l/ore_rdf?branch=master)
[![Gem Version](https://badge.fury.io/rb/ld4l-ore_rdf.svg)](http://badge.fury.io/rb/ld4l-ore_rdf)
[![Dependency Status](https://www.versioneye.com/ruby/ld4l-ore_rdf/0.0.3/badge.svg)](https://www.versioneye.com/ruby/ld4l-ore_rdf/0.0.3)



LD4L ORE RDF provides tools for modeling list triples based on the ORE ontology and persisting to a triplestore.


## Installation

Temporary get the gem from github until the gem is released publicly.

Add this line to your application's Gemfile:

gem 'ld4l-ore_rdf'
    

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ld4l-ore_rdf


## Primary Dependencies

* [ActiveTriples 0.10.0](https://github.com/ActiveTriples/ActiveTriples/tree/v0.10.0)
* [RDF 2.0.2](https://github.com/ruby-rdf/rdf/tree/2.0.2)

## Usage

**Caveat:** This gem is part of the LD4L Project and is being used in that context.  There is no guarantee that the 
code will work in a usable way outside of its use in LD4L Use Cases.

### Examples

*Setup required for all examples.*
```
require 'ld4l/ore_rdf'

# create an in-memory repository
ActiveTriples::Repositories.add_repository :default, RDF::Repository.new

# configure the solr url
ActiveTriples::Solrizer.configure do |config|
  config.solr_uri = "http://localhost:8983/solr/#/~cores/active_triples"
end


p = LD4L::FoafRDF::Person.new('p4')
```

*Example creating an aggregation with items individually.*

```
agg10 = LD4L::OreRDF::CreateAggregation.call( :id=>'agg10', :title=>'My Resources', :description=>'Resources that I like', :owner=>p )

LD4L::OreRDF::AddAggregatedResource.call( agg10,'http://exmple.org/resource_1')
LD4L::OreRDF::AddAggregatedResource.call( agg10,'http://exmple.org/resource_2')
LD4L::OreRDF::AddAggregatedResource.call( agg10,'http://exmple.org/resource_3')

LD4L::OreRDF::PersistAggregation.call(agg10)

# To resume the aggregation at a later time, use...
agg = LD4L::OreRDF::ResumeAggregation.call( 'agg10' )
```
*Example triples created for an aggregation.*

```
puts agg.dump :ttl

<http://localhost/agg10> a <http://www.openarchives.org/ore/terms/Aggregation>;
   <http://purl.org/dc/terms/title> "My Resources";
   <http://purl.org/dc/terms/creator> <http://localhost/p4>;
   <http://purl.org/dc/terms/description> "Resources that I like";
   <http://www.iana.org/assignments/relation/first> <http://localhost/pxeff9a617-ab30-4d7e-971f-825032a597b0>;
   <http://www.iana.org/assignments/relation/last> <http://localhost/pxd6577d16-7565-46c7-8b0f-31e7816b0e57>;
   <http://www.openarchives.org/ore/terms/aggregates> "http://exmple.org/resource_1",
     "http://exmple.org/resource_2",
     "http://exmple.org/resource_3" .
```

*Example triples created for each proxy in the list.*
```
puts agg.first_proxy.first.dump :ttl

<http://localhost/pxeff9a617-ab30-4d7e-971f-825032a597b0> a <http://www.openarchives.org/ore/terms/Proxy>;
   <http://www.iana.org/assignments/relation/next> <http://localhost/px0f16c9de-7d97-406d-a81a-a501bc209f79>;
   <http://www.openarchives.org/ore/terms/proxyFor> "http://exmple.org/resource_1";
   <http://www.openarchives.org/ore/terms/proxyIn> <http://localhost/agg10> .
   
puts agg.first_proxy.first.next_proxy.first.dump :ttl

<http://localhost/px0f16c9de-7d97-406d-a81a-a501bc209f79> a <http://www.openarchives.org/ore/terms/Proxy>;
   <http://www.iana.org/assignments/relation/next> <http://localhost/pxd6577d16-7565-46c7-8b0f-31e7816b0e57>;
   <http://www.iana.org/assignments/relation/prev> <http://localhost/pxeff9a617-ab30-4d7e-971f-825032a597b0>;
   <http://www.openarchives.org/ore/terms/proxyFor> "http://exmple.org/resource_2";
   <http://www.openarchives.org/ore/terms/proxyIn> <http://localhost/agg10> .
   
puts agg.last_proxy.first.dump :ttl

<http://localhost/pxd6577d16-7565-46c7-8b0f-31e7816b0e57> a <http://www.openarchives.org/ore/terms/Proxy>;
   <http://www.iana.org/assignments/relation/prev> <http://localhost/px0f16c9de-7d97-406d-a81a-a501bc209f79>;
   <http://www.openarchives.org/ore/terms/proxyFor> "http://exmple.org/resource_3";
   <http://www.openarchives.org/ore/terms/proxyIn> <http://localhost/agg10> .
```

*Example creating an aggregation with items in an array.*
```
agg11 = LD4L::OreRDF::CreateAggregation.call( :id=>'agg11', :title=>'More Resources', :description=>'More resources that I like', :owner=>p )

resources = [ 'http://exmple.org/resource_5', 'http://exmple.org/resource_6', 'http://exmple.org/resource_7' ]
LD4L::OreRDF::AddAggregatedResources.call( agg11,resources)

LD4L::OreRDF::PersistAggregation.call(agg11)

# To resume the aggregation at a later time, use...
agg = LD4L::OreRDF::ResumeAggregation.call( 'agg11' )
```

*Example triples created for an aggregation.*
```
puts agg.dump :ttl

<http://localhost/agg11> a <http://www.openarchives.org/ore/terms/Aggregation>;
   <http://purl.org/dc/terms/title> "More Resources";
   <http://purl.org/dc/terms/creator> <http://localhost/p4>;
   <http://purl.org/dc/terms/description> "More resources that I like";
   <http://www.iana.org/assignments/relation/first> <http://localhost/pxcff53ec2-f406-422b-92e6-f603612c9856>;
   <http://www.iana.org/assignments/relation/last> <http://localhost/px4788758e-640b-455c-91f8-10f3c255a72d>;
   <http://www.openarchives.org/ore/terms/aggregates> 
     "http://exmple.org/resource_5",
     "http://exmple.org/resource_6",
     "http://exmple.org/resource_7" .
```

*Example triples created for each proxy in the list.*
```
puts agg.first_proxy.first.dump :ttl

<http://localhost/pxcff53ec2-f406-422b-92e6-f603612c9856> a <http://www.openarchives.org/ore/terms/Proxy>;
   <http://www.iana.org/assignments/relation/next> <http://localhost/pxf7cd384a-2727-4201-8ebe-22c35302b6c0>;
   <http://www.openarchives.org/ore/terms/proxyFor> "http://exmple.org/resource_5";
   <http://www.openarchives.org/ore/terms/proxyIn> <http://localhost/agg11> .

puts agg.first_proxy.first.next_proxy.first.dump :ttl

<http://localhost/pxf7cd384a-2727-4201-8ebe-22c35302b6c0> a <http://www.openarchives.org/ore/terms/Proxy>;
   <http://www.iana.org/assignments/relation/next> <http://localhost/px4788758e-640b-455c-91f8-10f3c255a72d>;
   <http://www.iana.org/assignments/relation/prev> <http://localhost/pxcff53ec2-f406-422b-92e6-f603612c9856>;
   <http://www.openarchives.org/ore/terms/proxyFor> "http://exmple.org/resource_6";
   <http://www.openarchives.org/ore/terms/proxyIn> <http://localhost/agg11> .
   
puts agg.last_proxy.first.dump :ttl

<http://localhost/px4788758e-640b-455c-91f8-10f3c255a72d> a <http://www.openarchives.org/ore/terms/Proxy>;
   <http://www.iana.org/assignments/relation/prev> <http://localhost/pxf7cd384a-2727-4201-8ebe-22c35302b6c0>;
   <http://www.openarchives.org/ore/terms/proxyFor> "http://exmple.org/resource_7";
   <http://www.openarchives.org/ore/terms/proxyIn> <http://localhost/agg11> .
```

#### Example: Find all aggregations
```
# Find all and return only the URIs for each aggregation
aggregation_uris = LD4L::OreRDF::FindAggregations.call

# Find all and return title and description
aggregation_properties = LD4L::OreRDF::FindAggregations.call(
    :properties => { :title => RDF::Vocab::DC.title, :description => RDF::Vocab::DC.description } )

```


### Configurations

* base_uri - base URI used when new resources are created (default="http://localhost/")
* localname_minter - minter function to use for creating unique local names (default=nil which uses default minter in active_triples-local_name gem)

*Setup for all examples.*

* Restart your interactive session (e.g. irb, pry).
* Use the Setup for all examples in main Examples section above.

*Example usage using configured base_uri and default localname_minter.*
```
LD4L::OreRDF.configure do |config|
  config.base_uri = "http://example.org/"
end

a = LD4L::OreRDF::AggregationResource.new(ActiveTriples::LocalName::Minter.generate_local_name(
              LD4L::OreRDF::AggregationResource, 10, {:prefix=>'ag'} ))

puts a.dump :ttl
```
NOTE: If base_uri is not used, you need to restart your interactive environment (e.g. irb, pry).  Once the 
  Aggregation class is instantiated the first time, the base_uri for the class is set.  If you ran
  through the main Examples, the base_uri was set to the default base_uri.


*Example triples created for an aggregation with configured base_uri and default minter.*
```
<http://example.org/ag45c9c85b-25af-4c52-96a4-cf0d8b70a768> a <http://www.openarchives.org/ore/terms/Aggregation> .
```

*Example usage using configured base_uri and configured localname_minter.*
```
LD4L::OreRDF.configure do |config|
  config.base_uri = "http://example.org/"
  config.localname_minter = lambda { |prefix=""| prefix+'_configured_'+SecureRandom.uuid }
end

a = LD4L::OreRDF::AggregationResource.new(ActiveTriples::LocalName::Minter.generate_local_name(
              LD4L::OreRDF::AggregationResource, 10, 'ag',
              &LD4L::OreRDF.configuration.localname_minter ))

puts a.dump :ttl
```
NOTE: If base_uri is not used, you need to restart your interactive environment (e.g. irb, pry).  Once the 
  Aggregation class is instantiated the first time, the base_uri for the class is set.  If you ran
  through the main Examples, the base_uri was set to the default base_uri.


*Example triples created for an aggregation with configured base_uri and configured minter.*
```
<http://example.org/ag_configured_6498ba05-8b21-4e8c-b9d4-a6d5d2180966> a <http://www.openarchives.org/ore/terms/Aggregation> .
   ```


### Models

The LD4L::OreRDF gem provides model definitions using the 
[ActiveTriples](https://github.com/ActiveTriples/ActiveTriples) framework extension of 
[ruby-rdf/rdf](https://github.com/ruby-rdf/rdf).  The following models are provided:

1. LD4L::OreRDF::AggregationResource - Implements the Aggregation class in the ORE ontology.
1. LD4L::OreRDF::ProxyResource - Implements the Proxy class in the ORE ontology.

### Ontologies

The listed ontologies are used to represent the primary metadata about aggregation lists.
Other ontologies may also be used that aren't listed.
 
* [ORE](http://www.openarchives.org/ore/1.0/vocabulary)
* [FOAF](http://xmlns.com/foaf/spec/)
* [RDF](http://www.w3.org/TR/rdf-syntax-grammar/)


## Contributing

1. Fork it ( https://github.com/[my-github-username]/ld4l-ore_rdf/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
