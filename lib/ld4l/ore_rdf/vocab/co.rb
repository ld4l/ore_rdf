require 'rdf'
module RDFVocabularies
  class CO < RDF::Vocabulary("http://purl.org/co#")

    # Class definitions
    term :Set                # used for unordered lists
    term :List               # used for ordered lists
    term :Element            # used for items in an unordered list
    term :ListItem           # used for items in an ordered list

    # Property definitions for CO.Set and CO.List
    property :size           # xsd:nonNegativeInteger -- count of all Elements/ListItems in this list
    property :item           # URI of each ListItem in this List

    # Property definitions for CO.List
    property :firstItem      # URI to first ListItem in an ordered list
    property :lastItem       # URI to last ListItem in an ordered list

    # Property definitions for CO.Element and CO.ListItem
    property :itemContent    # URI to any content

    # Property definitions for CO.ListItem
    property :index          # xsd:positiveInteger -- index of each ListItem starting at 1 counting up
    property :nextItem       # URI to a ListItem
    property :previousItem   # URI to a ListItem
  end
end
