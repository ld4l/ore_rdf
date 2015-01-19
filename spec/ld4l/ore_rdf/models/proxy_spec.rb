require 'spec_helper'

describe 'LD4L::OreRDF::Proxy' do

  subject { LD4L::OreRDF::Proxy.new }  # new virtual collection without a subject

  describe 'rdf_subject' do
    it "should be a blank node if we haven't set it" do
      expect(subject.rdf_subject.node?).to be true
    end

    it "should be settable when it has not been set yet" do
      subject.set_subject! RDF::URI('http://example.org/moomin')
      expect(subject.rdf_subject).to eq RDF::URI('http://example.org/moomin')
    end

    it "should append to base URI when setting to non-URI subject" do
      subject.set_subject! '123'
      expect(subject.rdf_subject).to eq RDF::URI("#{LD4L::OreRDF::Proxy.base_uri}123")
    end

    describe 'when changing subject' do
      before do
        subject << RDF::Statement.new(subject.rdf_subject, RDF::DC.title, RDF::Literal('Comet in Moominland'))
        subject << RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::DC.isPartOf, subject.rdf_subject)
        subject << RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::DC.relation, 'http://example.org/moomin_land')
        subject.set_subject! RDF::URI('http://example.org/moomin')
      end

      it 'should update graph subjects' do
        expect(subject.has_statement?(RDF::Statement.new(subject.rdf_subject, RDF::DC.title, RDF::Literal('Comet in Moominland')))).to be true
      end

      it 'should update graph objects' do
        expect(subject.has_statement?(RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::DC.isPartOf, subject.rdf_subject))).to be true
      end

      it 'should leave other uris alone' do
        expect(subject.has_statement?(RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::DC.relation, 'http://example.org/moomin_land'))).to be true
      end
    end

    describe 'created with URI subject' do
      before do
        subject.set_subject! RDF::URI('http://example.org/moomin')
      end

      it 'should not be settable' do
        expect{ subject.set_subject! RDF::URI('http://example.org/moomin2') }.to raise_error
      end
    end
  end


  # -------------------------------------------------
  #  START -- Test attributes specific to this model
  # -------------------------------------------------

  describe 'type' do
    it "should be an RDFVocabularies::ORE.Proxy" do
      expect(subject.type.first.value).to eq RDFVocabularies::ORE.Proxy.value
    end
  end

  describe 'proxy_for' do
    it "should be empty array if we haven't set it" do
      expect(subject.proxy_for).to match_array([])
    end

    it "should be settable" do
      subject.proxy_for = RDF::URI("http://example.org/b1")
      expect(subject.proxy_for.first.rdf_subject).to eq RDF::URI("http://example.org/b1")
    end

    it "should be changeable" do
      orig_proxy_for = RDF::URI("http://example.org/b1")
      new_proxy_for  = RDF::URI("http://example.org/b1_NEW")
      subject.proxy_for = orig_proxy_for
      subject.proxy_for = new_proxy_for
      expect(subject.proxy_for.first.rdf_subject).to eq new_proxy_for
    end
  end

  describe 'proxy_in' do
    it "should be empty array if we haven't set it" do
      expect(subject.proxy_in).to match_array([])
    end

    it "should be settable" do
      an_aggregation = LD4L::OreRDF::Aggregation.new('1')
      subject.proxy_in = an_aggregation
      expect(subject.proxy_in.first).to eq an_aggregation
    end

    it "should be changeable" do
      orig_aggregation = LD4L::OreRDF::Aggregation.new('1')
      new_aggregation = LD4L::OreRDF::Aggregation.new('2')
      subject.proxy_in = orig_aggregation
      subject.proxy_in = new_aggregation
      expect(subject.proxy_in.first).to eq new_aggregation
    end
  end

  describe 'next_proxy' do
    it "should be empty array if we haven't set it" do
      expect(subject.next_proxy).to match_array([])
    end

    it "should be settable" do
      an_proxy = LD4L::OreRDF::Proxy.new('1')
      subject.next_proxy = an_proxy
      expect(subject.next_proxy.first).to eq an_proxy
    end

    it "should be changeable" do
      orig_proxy = LD4L::OreRDF::Proxy.new('1')
      new_proxy = LD4L::OreRDF::Proxy.new('2')
      subject.next_proxy = orig_proxy
      subject.next_proxy = new_proxy
      expect(subject.next_proxy.first).to eq new_proxy
    end
  end

  describe 'prev_proxy' do
    it "should be empty array if we haven't set it" do
      expect(subject.prev_proxy).to match_array([])
    end

    it "should be settable" do
      an_proxy = LD4L::OreRDF::Proxy.new('1')
      subject.prev_proxy = an_proxy
      expect(subject.prev_proxy.first).to eq an_proxy
    end

    it "should be changeable" do
      orig_proxy = LD4L::OreRDF::Proxy.new('1')
      new_proxy = LD4L::OreRDF::Proxy.new('2')
      subject.prev_proxy = orig_proxy
      subject.prev_proxy = new_proxy
      expect(subject.prev_proxy.first).to eq new_proxy
    end
  end

  describe 'contributor' do
    it "should be empty array if we haven't set it" do
      expect(subject.contributor).to match_array([])
    end

    it "should be settable" do
      a_person = LD4L::FoafRDF::Person.new('1')
      subject.contributor = a_person
      expect(subject.contributor.first).to eq a_person
    end

    it "should be changeable" do
      orig_person = LD4L::FoafRDF::Person.new('1')
      new_person = LD4L::FoafRDF::Person.new('2')
      subject.contributor = orig_person
      subject.contributor = new_person
      expect(subject.contributor.first).to eq  new_person
    end
  end

  # -----------------------------------------------
  #  END -- Test attributes specific to this model
  # -----------------------------------------------


  # -----------------------------------------------------
  #  START -- Test helper methods specific to this model
  # -----------------------------------------------------


  ########### NEED TO MOVE TO SERVICE OBJECT ####################


  describe "#get_range" do
    context "when collection has 0 items" do
      it "should return empty array when no items exist" do
        vc  = LD4L::OreRDF::Aggregation.new
        vc.aggregates = []
        vci_array = LD4L::OreRDF::Proxy.get_range(vc)
        expect(vci_array).to eq []
      end
    end

    context "when collection has items" do
      before do
        vc.aggregates = []
        vc.persist!


        ###  TODO need to update add_items_with_content to use new service


        # vci_array = vc.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
        #                                        RDF::URI("http://example.org/individual/b2"),
        #                                        RDF::URI("http://example.org/individual/b3")])



        vc.persist!
        vci_array.each { |vci| vci.persist! }
      end

      let(:vc) { LD4L::OreRDF::Aggregation.new }

      xit "should return array" do


        ###  TODO need to update add_items_with_content in BEFORE to use new service


        vci_array = LD4L::OreRDF::Proxy.get_range(vc)
        expect(vci_array).to be_a(Array)
        expect(vci_array.size).to eq(3)
      end

      xit "should return array of LD4L::OreRDF::Proxy instances" do


        ###  TODO need to update add_items_with_content in BEFORE to use new service


        vci_array = LD4L::OreRDF::Proxy.get_range(vc)
        vci_array.each do |vci|
          expect(vci).to be_a(LD4L::OreRDF::Proxy)
        end
        expect(vci_array.size).to eq(3)
      end
    end

    context "when start and limit are not specified" do
      context "and objects not persisted" do
        before do
          vc.aggregates = []
          vc.persist!


          ###  TODO need to update add_items_with_content to use new service


          # vc.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
          #                            RDF::URI("http://example.org/individual/b2"),
          #                            RDF::URI("http://example.org/individual/b3")])
        end

        let(:vc) { LD4L::OreRDF::Aggregation.new }

        xit "should return empty array" do


          ###  TODO need to update add_items_with_content in BEFORE to use new service


          vci_array = LD4L::OreRDF::Proxy.get_range(vc)
          expect(vci_array.size).to eq(0)
        end
      end

      context "and objects are persisted" do
        before do
          vc.aggregates = []
          vc.persist!


          ###  TODO need to update add_items_with_content to use new service


          # vci_array = vc.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
          #                                        RDF::URI("http://example.org/individual/b2"),
          #                                        RDF::URI("http://example.org/individual/b3")])
          vc.persist!
          vci_array.each { |vci| vci.persist! }
        end

        let(:vc) { LD4L::OreRDF::Aggregation.new }

        xit "should return array of all LD4L::OreRDF::Proxy instances for content aggregated by subject" do


          ###  TODO need to update add_items_with_content in BEFORE to use new service


          vci_array = LD4L::OreRDF::Proxy.get_range(vc)
          vci_array.each do |vci|
            expect(vci).to be_a(LD4L::OreRDF::Proxy)
            expect(vci.proxy_in.first).to eq vc
          end
          results = []
          vci_array.each { |vci| results << vci.proxy_for.first }
          expect(results).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b1"))
          expect(results).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b2"))
          expect(results).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b3"))
          expect(vci_array.size).to eq(3)
        end

        xit "should not return any LD4L::OreRDF::Proxy instances for content not aggregated by subject" do
          pending "this needs to be implemented"
        end
      end
    end

    context "when limit is specified" do
      xit "should return array of LD4L::OreRDF::Proxy instances with max size=limit" do
        pending "this needs to be implemented"
      end
    end

    context "when start is specified" do
      xit "should return array of LD4L::OreRDF::Proxy instances_beginning with item at position=start" do
        # TODO: What does _start_ mean in ActiveTriples?  Does it support this kind of query?
        pending "this needs to be implemented"
      end
    end

    context "when start and limit are specified" do
      xit "should return an array of LD4L::OreRDF::Proxy instances with max size=limit beginning with item at position=start" do
        pending "this needs to be implemented"
      end
    end
  end

  # ---------------------------------------------------
  #  END -- Test helper methods specific to this model
  # ---------------------------------------------------


  describe "#persisted?" do
    context 'with a repository' do
      before do
        # Create inmemory repository
        repository = RDF::Repository.new
        allow(subject).to receive(:repository).and_return(repository)
      end

      context "when the object is new" do
        it "should return false" do
          expect(subject).not_to be_persisted
        end
      end

      context "when it is saved" do
        before do
          subject.contributor = "John Smith"
          subject.persist!
        end

        it "should return true" do
          expect(subject).to be_persisted
        end

        context "and then modified" do
          before do
            subject.contributor = "New Smith"
          end

          it "should return true" do
            expect(subject).to be_persisted
          end
        end
        context "and then reloaded" do
          before do
            subject.reload
          end

          it "should reset the contributor" do
            expect(subject.contributor).to eq ["John Smith"]
          end

          it "should be persisted" do
            expect(subject).to be_persisted
          end
        end
      end
    end
  end

  describe "#persist!" do
    context "when the repository is set" do
      context "and the item is not a blank node" do

        subject {LD4L::OreRDF::Proxy.new("123")}

        before do
          # Create inmemory repository
          @repo = RDF::Repository.new
          allow(subject.class).to receive(:repository).and_return(nil)
          allow(subject).to receive(:repository).and_return(@repo)
          subject.contributor = "John Smith"
          an_aggregation = LD4L::OreRDF::Aggregation.new('1')
          subject.proxy_in = an_aggregation
          subject.proxy_for = RDF::URI("http://example.org/b1")
          subject.persist!
        end

        it "should persist to the repository" do
          expect(@repo.statements.first).to eq subject.statements.first
        end

        it "should delete from the repository" do
          subject.reload
          expect(subject.contributor).to eq ["John Smith"]
          subject.contributor = []
          subject.proxy_in = []
          subject.proxy_for = []
          expect(subject.contributor).to eq []
          subject.persist!
          subject.reload
          expect(subject.contributor).to eq []
          expect(@repo.statements.to_a.length).to eq 1 # Only the type statement
        end
      end

      context "and the item is created by create method" do


        ###  TODO need to update create to use new service


        # subject { LD4L::OreRDF::Proxy.create(id: "123", aggregation: LD4L::OreRDF::Aggregation.new('1'), content: RDF::URI("http://example.org/b1"), contributor: "John Smith")}

        before do
          # Create inmemory repository
          @repo = RDF::Repository.new
          allow(subject.class).to receive(:repository).and_return(nil)
          allow(subject).to receive(:repository).and_return(@repo)
          subject.persist!
        end

        xit "should persist to the repository" do
          expect(@repo.statements.first).to eq subject.statements.first
        end

        xit "should delete from the repository" do
          subject.reload
          expect(subject.contributor).to eq ["John Smith"]
          subject.contributor = []
          subject.proxy_in = []
          subject.proxy_for = []
          expect(subject.contributor).to eq []
          subject.persist!
          subject.reload
          expect(subject.contributor).to eq []
          expect(@repo.statements.to_a.length).to eq 1 # Only the type statement
        end
      end
    end
  end

  describe '#destroy!' do
    before do
      subject << RDF::Statement(RDF::DC.LicenseDocument, RDF::DC.title, 'LICENSE')
    end

    subject { LD4L::FoafRDF::Person.new('456')}

    it 'should return true' do
      expect(subject.destroy!).to be true
      expect(subject.destroy).to be true
    end

    it 'should delete the graph' do
      subject.destroy
      expect(subject).to be_empty
    end

    context 'with a parent' do
      before do
        parent.contributor = subject
      end

      let(:parent) do
        LD4L::OreRDF::Proxy.new('123')
      end

      it 'should empty the graph and remove it from the parent' do
        subject.destroy
        expect(parent.contributor).to be_empty
      end

      it 'should remove its whole graph from the parent' do
        subject.destroy
        subject.each_statement do |s|
          expect(parent.statements).not_to include s
        end
      end
    end
  end

  describe 'attributes' do
    before do
      subject.contributor = contributor
      subject.proxy_for = 'Dummy Proxy'
    end

    subject {LD4L::OreRDF::Proxy.new("123")}

    let(:contributor) { LD4L::FoafRDF::Person.new('456') }

    it 'should return an attributes hash' do
      expect(subject.attributes).to be_a Hash
    end

    it 'should contain data' do
      expect(subject.attributes['proxy_for']).to eq ['Dummy Proxy']
    end

    it 'should contain child objects' do
      expect(subject.attributes['contributor']).to eq [contributor]
    end

    context 'with unmodeled data' do
      before do
        subject << RDF::Statement(subject.rdf_subject, RDF::DC.creator, 'Tove Jansson')
        subject << RDF::Statement(subject.rdf_subject, RDF::DC.relation, RDF::URI('http://example.org/moomi'))
        node = RDF::Node.new
        subject << RDF::Statement(RDF::URI('http://example.org/moomi'), RDF::DC.relation, node)
        subject << RDF::Statement(node, RDF::DC.title, 'bnode')
      end

      it 'should include data with URIs as attribute names' do
        expect(subject.attributes[RDF::DC.creator.to_s]).to eq ['Tove Jansson']
      end

      it 'should return generic Resources' do
        expect(subject.attributes[RDF::DC.relation.to_s].first).to be_a ActiveTriples::Resource
      end

      it 'should build deep data for Resources' do
        expect(subject.attributes[RDF::DC.relation.to_s].first.get_values(RDF::DC.relation).
                   first.get_values(RDF::DC.title)).to eq ['bnode']
      end

      it 'should include deep data in serializable_hash' do
        expect(subject.serializable_hash[RDF::DC.relation.to_s].first.get_values(RDF::DC.relation).
                   first.get_values(RDF::DC.title)).to eq ['bnode']
      end
    end

    describe 'attribute_serialization' do
      describe '#to_json' do
        it 'should return a string with correct objects' do
          json_hash = JSON.parse(subject.to_json)
          expect(json_hash['contributor'].first['id']).to eq contributor.rdf_subject.to_s
        end
      end
    end
  end

  describe 'property methods' do
    it 'should set and get properties' do
      subject.proxy_for = 'Comet in Moominland'
      expect(subject.proxy_for).to eq ['Comet in Moominland']
    end
  end

  describe 'child nodes' do
    it 'should return an object of the correct class when the value is built from the base URI' do
      subject.contributor = LD4L::FoafRDF::Person.new('456')
      expect(subject.contributor.first).to be_kind_of LD4L::FoafRDF::Person
    end

    it 'should return an object with the correct URI created with a URI' do
      subject.contributor = LD4L::FoafRDF::Person.new("http://example.org/license")
      expect(subject.contributor.first.rdf_subject).to eq RDF::URI("http://example.org/license")
    end

    it 'should return an object of the correct class when the value is a bnode' do
      subject.contributor = LD4L::FoafRDF::Person.new
      expect(subject.contributor.first).to be_kind_of LD4L::FoafRDF::Person
    end
  end

  describe '#rdf_label' do
    subject {LD4L::OreRDF::Proxy.new("123")}

    it 'should return an array of label values' do
      expect(subject.rdf_label).to be_kind_of Array
    end

    it 'should return the default label as URI when no title property exists' do
      expect(subject.rdf_label.first).to eq "#{LD4L::OreRDF::Proxy.base_uri}123"
    end

    it 'should prioritize configured label values' do
      custom_label = RDF::URI('http://example.org/custom_label')
      subject.class.configure :rdf_label => custom_label
      subject << RDF::Statement(subject.rdf_subject, custom_label, RDF::Literal('New Label'))
      expect(subject.rdf_label).to eq ['New Label']
    end
  end

  describe '#solrize' do
    it 'should return a label for bnodes' do
      expect(subject.solrize).to eq subject.rdf_label
    end

    it 'should return a string of the resource uri' do
      subject.set_subject! 'http://example.org/moomin'
      expect(subject.solrize).to eq 'http://example.org/moomin'
    end
  end

  describe 'editing the graph' do
    it 'should write properties when statements are added' do
      subject << RDF::Statement.new(subject.rdf_subject, RDFVocabularies::ORE.proxyFor, 'Comet in Moominland')
      expect(subject.proxy_for).to include 'Comet in Moominland'
    end

    it 'should delete properties when statements are removed' do
      subject << RDF::Statement.new(subject.rdf_subject, RDFVocabularies::ORE.proxyFor, 'Comet in Moominland')
      subject.delete RDF::Statement.new(subject.rdf_subject, RDFVocabularies::ORE.proxyFor, 'Comet in Moominland')
      expect(subject.proxy_for).to eq []
    end
  end

  describe 'big complex graphs' do
    before do
      class DummyPerson < ActiveTriples::Resource
        configure :type => RDF::URI('http://example.org/Person')
        property :foafname, :predicate => RDF::FOAF.name
        property :publications, :predicate => RDF::FOAF.publications, :class_name => 'DummyDocument'
        property :knows, :predicate => RDF::FOAF.knows, :class_name => DummyPerson
      end

      class DummyDocument < ActiveTriples::Resource
        configure :type => RDF::URI('http://example.org/Document')
        property :title, :predicate => RDF::DC.title
        property :creator, :predicate => RDF::DC.creator, :class_name => 'DummyPerson'
      end

      LD4L::OreRDF::Proxy.property :item, :predicate => RDF::DC.relation, :class_name => DummyDocument
    end

    subject { LD4L::OreRDF::Proxy.new }

    let (:document1) do
      d = DummyDocument.new
      d.title = 'Document One'
      d
    end

    let (:document2) do
      d = DummyDocument.new
      d.title = 'Document Two'
      d
    end

    let (:person1) do
      p = DummyPerson.new
      p.foafname = 'Alice'
      p
    end

    let (:person2) do
      p = DummyPerson.new
      p.foafname = 'Bob'
      p
    end

    let (:data) { <<END
_:1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/SomeClass> .
_:1 <http://purl.org/dc/terms/relation> _:2 .
_:2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/Document> .
_:2 <http://purl.org/dc/terms/title> "Document One" .
_:2 <http://purl.org/dc/terms/creator> _:3 .
_:2 <http://purl.org/dc/terms/creator> _:4 .
_:4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/Person> .
_:4 <http://xmlns.com/foaf/0.1/name> "Bob" .
_:3 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/Person> .
_:3 <http://xmlns.com/foaf/0.1/name> "Alice" .
_:3 <http://xmlns.com/foaf/0.1/knows> _:4 ."
END
    }

    after do
      Object.send(:remove_const, "DummyDocument")
      Object.send(:remove_const, "DummyPerson")
    end

    it 'should allow access to deep nodes' do
      document1.creator = [person1, person2]
      document2.creator = person1
      person1.knows = person2
      subject.item = [document1]
      expect(subject.item.first.creator.first.knows.first.foafname).to eq ['Bob']
    end
  end
end
