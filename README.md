#LD4L::OreRDF

LD4L ORE RDF provides tools for modeling list triples based on the ORE ontology and persisting to a triplestore.


## Installation

Temporary get the gem from github until the gem is released publicly.

Add this line to your application's Gemfile:

<!--    gem 'ld4l-ore_rdf' -->
    gem 'ld4l-ore_rdf', '~> 0.0.3', :git => 'git@github.com:ld4l/ore_rdf.git'
    

And then execute:

    $ bundle install

<!--
Or install it yourself as:

    $ gem install ld4l-ore_rdf
-->


## Usage

**Caveat:** This gem is part of the LD4L Project and is being used in that context.  There is no guarantee that the 
code will work in a usable way outside of its use in LD4L Use Cases.

### Examples

TBA


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

a = LD4L::OreRDF::Aggregation.new(ActiveTriples::LocalName::Minter.generate_local_name(
              LD4L::OreRDF::Aggregation, 10, {:prefix=>'a'} ))

puts a.dump :ttl
```
NOTE: If base_uri is not used, you need to restart your interactive environment (e.g. irb, pry).  Once the 
  Aggregation class is instantiated the first time, the base_uri for the class is set.  If you ran
  through the main Examples, the base_uri was set to the default base_uri.


*Example triples created for a person with configured base_uri and default minter.*
```
# TODO Update Type URI
<http://example.org/a45c9c85b-25af-4c52-96a4-cf0d8b70a768> a <http://www.w3.org/ns/oa#Annotation> .
```

*Example usage using configured base_uri and configured localname_minter.*
```
LD4L::OreRDF.configure do |config|
  config.base_uri = "http://example.org/"
  config.localname_minter = lambda { |prefix=""| prefix+'_configured_'+SecureRandom.uuid }
end

a = LD4L::OreRDF::Aggregation.new(ActiveTriples::LocalName::Minter.generate_local_name(
              LD4L::OreRDF::Aggregation, 10, 'a',
              &LD4L::OreRDF.configuration.localname_minter ))

puts a.dump :ttl
```
NOTE: If base_uri is not used, you need to restart your interactive environment (e.g. irb, pry).  Once the 
  Aggregation class is instantiated the first time, the base_uri for the class is set.  If you ran
  through the main Examples, the base_uri was set to the default base_uri.


*Example triples created for a person with configured base_uri and configured minter.*
```
# TODO Update Type URI
<http://example.org/a_configured_6498ba05-8b21-4e8c-b9d4-a6d5d2180966> a <http://www.w3.org/ns/oa#Annotation> .
```


### Models

The LD4L::OreRDF gem provides model definitions using the 
[ActiveTriples](https://github.com/ActiveTriples/ActiveTriples) framework extension of 
[ruby-rdf/rdf](https://github.com/ruby-rdf/rdf).  The following models are provided:

1. LD4L::OreRDF::Aggregation - Implements the Aggregation class in the ORE ontology.
1. LD4L::OreRDF::Proxy - Implements the Proxy class in the ORE ontology.

### Ontologies

The listed ontologies are used to represent the primary metadata about the person.
Other ontologies may also be used that aren't listed.
 
TODO - Add ORE ontology;  maybe remove FOAF 
* [FOAF](http://xmlns.com/ore/spec/)
* [RDF](http://www.w3.org/TR/rdf-syntax-grammar/)


## Contributing

1. Fork it ( https://github.com/[my-github-username]/ld4l-ore_rdf/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
