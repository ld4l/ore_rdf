require 'rdf'
module RDFVocabularies
  class DCTERMS < RDF::Vocabulary("http://purl.org/dc/terms/")
    property :format
  end
end
