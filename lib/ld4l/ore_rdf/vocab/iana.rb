# require 'rdf'
module RDFVocabularies
  class IANA < RDF::Vocabulary("http://www.iana.org/assignments/relation/")
    property :first   # URI of first item - An IRI that refers to the furthest preceding resource in a series of resources.
    property :last    # URI of last item - An IRI that refers to the furthest following resource in a series of resources.
    property :next    # URI of next item - Indicates that the link's context is a part of a series, and that the next in the series is the link target.
    property :prev    # URI of previous item - Indicates that the link's context is a part of a series, and that the previous in the series is the link target.
  end
end
