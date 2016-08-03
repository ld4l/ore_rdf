require 'spec_helper'

describe 'LD4L::OreRDF::AggregationResource' do

  subject { LD4L::OreRDF::AggregationResource.new }  # new virtual collection without a subject

  describe '#rdf_subject' do
    it "should be a blank node if we haven't set it" do
      expect(subject.rdf_subject.node?).to be true
    end

    it "should be settable when it has not been set yet" do
      subject.set_subject! RDF::URI('http://example.org/moomin')
      expect(subject.rdf_subject).to eq RDF::URI('http://example.org/moomin')
    end

    it "should append to base URI when setting to non-URI subject" do
      subject.set_subject! '123'
      expect(subject.rdf_subject).to eq RDF::URI("#{LD4L::OreRDF::AggregationResource.base_uri}123")
    end

    describe 'when changing subject' do
      before do
        subject << RDF::Statement.new(subject.rdf_subject, RDF::Vocab::DC.title, RDF::Literal('Comet in Moominland'))
        subject << RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::Vocab::DC.isPartOf, subject.rdf_subject)
        subject << RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::Vocab::DC.relation, 'http://example.org/moomin_land')
        subject.set_subject! RDF::URI('http://example.org/moomin')
      end

      it 'should update graph subjects' do
        expect(subject.has_statement?(RDF::Statement.new(subject.rdf_subject, RDF::Vocab::DC.title, RDF::Literal('Comet in Moominland')))).to be true
      end

      it 'should update graph objects' do
        expect(subject.has_statement?(RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::Vocab::DC.isPartOf, subject.rdf_subject))).to be true
      end

      it 'should leave other uris alone' do
        expect(subject.has_statement?(RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::Vocab::DC.relation, 'http://example.org/moomin_land'))).to be true
      end
    end

    describe 'created with URI subject' do
      before do
        subject.set_subject! RDF::URI('http://example.org/moomin')
      end

      it 'should not be settable' do
        expect{ subject.set_subject! RDF::URI('http://example.org/moomin2') }.to raise_error(RuntimeError, 'Refusing update URI when one is already assigned!')
      end
    end
  end


  # -------------------------------------------------
  #  START -- Test attributes specific to this model
  # -------------------------------------------------

  describe 'type' do
    it "should be an ORE.Aggregation" do
      expect(subject.type.first.value).to eq RDF::Vocab::ORE.Aggregation.value
    end
  end

  describe 'title' do
    it "should be empty array if we haven't set it" do
      expect(subject.title).to match_array([])
    end

    it "should be settable" do
      subject.title = "Test Title"
      expect(subject.title).to eq ["Test Title"]
    end

    it "should be changeable" do
      subject.title = "Test Title"
      subject.title = "New Title"
      expect(subject.title).to eq ["New Title"]
    end
  end

  describe 'description' do
    it "should be empty array if we haven't set it" do
      expect(subject.description).to match_array([])
    end

    it "should be settable" do
      subject.description = "Test Description"
      expect(subject.description).to eq ["Test Description"]
    end

    it "should be changeable" do
      subject.description = "Test Description"
      subject.description = "New Description"
      expect(subject.description).to eq ["New Description"]
    end
  end

  describe 'owner' do
    it "should be empty array if we haven't set it" do
      expect(subject.owner).to match_array([])
    end

    it "should be settable" do
      a_person = LD4L::FoafRDF::Person.new('1')
      subject.owner = a_person
      expect(subject.owner.first.rdf_subject).to eq a_person.rdf_subject
    end

    it "should be changeable" do
      orig_person = LD4L::FoafRDF::Person.new('1')
      new_person = LD4L::FoafRDF::Person.new('2')
      subject.owner = orig_person
      subject.owner = new_person
      expect(subject.owner.first.rdf_subject).to eq  new_person.rdf_subject
    end
  end

  describe 'aggregates' do
    it "should be empty array if we haven't set it" do
      expect(subject.aggregates).to match_array([])
    end

    it "should be set to a URI producing an ActiveTriple::Resource" do
      subject.aggregates = "http://example.org/individual/b1"
      expect(subject.aggregates.first).to be_a String
      expect(subject.aggregates.first).to eq "http://example.org/individual/b1"
    end

    it "should be settable" do
      subject.aggregates = "http://example.org/individual/b1"
      expect(subject.aggregates.first).to eq "http://example.org/individual/b1"
    end

    it "should be settable to multiple values" do
      bib1 = "http://example.org/individual/b1"
      bib2 = "http://example.org/individual/b2"
      bib3 = "http://example.org/individual/b3"
      subject.aggregates = bib1
      subject.aggregates << bib2
      subject.aggregates << bib3
      expect(subject.aggregates).to match_array [bib1,bib2,bib3]
    end

    it "should be changeable" do
      orig_bib = "http://example.org/individual/b1"
      new_bib  = "http://example.org/individual/b1_NEW"
      subject.aggregates = orig_bib
      subject.aggregates = new_bib
      expect(subject.aggregates.first).to eq new_bib
    end

    it "should be changeable for multiple values" do
      orig_bib1 = "http://example.org/individual/b1"
      orig_bib2 = "http://example.org/individual/b2"
      orig_bib3 = "http://example.org/individual/b3"

      new_bib1 = "http://example.org/individual/b1_NEW"
      new_bib3 = "http://example.org/individual/b3_NEW"

      subject.aggregates = orig_bib1
      subject.aggregates << orig_bib2
      subject.aggregates << orig_bib3

      if subject.respond_to? 'persistence_strategy'  # >= ActiveTriples 0.8
        aggregates = subject.aggregates.to_a
      else  # < ActiveTriples 0.8
        aggregates = subject.aggregates.dup
      end
      aggregates[aggregates.index(orig_bib1)] = new_bib1
      aggregates[aggregates.index(orig_bib3)] = new_bib3
      subject.aggregates = aggregates

      expect(subject.aggregates).to include new_bib1
      expect(subject.aggregates).to include orig_bib2
      expect(subject.aggregates).to include new_bib3
    end

    it "should be directly changeable for multiple values" do
      orig_bib1 = "http://example.org/individual/b1"
      orig_bib2 = "http://example.org/individual/b2"
      orig_bib3 = "http://example.org/individual/b3"

      new_bib1 = "http://example.org/individual/b1_NEW"
      new_bib3 = "http://example.org/individual/b3_NEW"

      subject.aggregates = orig_bib1
      subject.aggregates << orig_bib2
      subject.aggregates << orig_bib3

      if subject.respond_to? 'persistence_strategy'  # >= ActiveTriples 0.8
        subject.aggregates.swap(orig_bib1, new_bib1)
        subject.aggregates.swap(orig_bib3, new_bib3)
      else  # < ActiveTriples 0.8
        aggregates[aggregates.index(orig_bib1)] = new_bib1
        aggregates[aggregates.index(orig_bib3)] = new_bib3
      end
      expect(subject.aggregates).to include new_bib1
      expect(subject.aggregates).to include orig_bib2
      expect(subject.aggregates).to include new_bib3
    end
  end

  # -----------------------------------------------
  #  END -- Test attributes specific to this model
  # -----------------------------------------------


  # -----------------------------------------------------
  #  START -- Test helper methods specific to this model
  # -----------------------------------------------------

  describe '#generate_solr_document' do
    before do
      ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
      @person = LD4L::FoafRDF::Person.new('http://example.org/person1')
      @aggregation = LD4L::OreRDF::CreateAggregation.call( :id=>'http://example.org/moomin', :title=>'My Resources',
                                                           :description=>'Resources that I like', :owner=>@person )
    end

    context 'when aggregation has 0 proxies' do
      it 'should return a solr doc with all fields' do
        expected_solr_doc = {:id=>"http://example.org/moomin",
                             :at_model_ssi=>"LD4L::OreRDF::AggregationResource",
                             :object_profile_ss=>
                                 "{\"id\":\"http://example.org/moomin\",\"title\":[\"My Resources\"],\"description\":[\"Resources that I like\"],\"owner\":\"http://example.org/person1\",\"aggregates\":[],\"first_proxy_\":[],\"last_proxy_\":[]}",
                             :title_ti=>"My Resources",
                             :title_ssort=>"My Resources",
                             :description_ti=>"Resources that I like",
                             :owner_ssi=>"http://example.org/person1",
                             :item_proxies_ssm=>[]}
        expect(@aggregation.aggregation_resource.generate_solr_document(@aggregation.proxy_resources)).to eq expected_solr_doc
      end
    end

    context 'when aggregation has proxies' do
      let(:proxies) do
        [LD4L::OreRDF::AddAggregatedResource.call( @aggregation,'http://example.org/resource_1'),
         LD4L::OreRDF::AddAggregatedResource.call( @aggregation,'http://example.org/resource_2'),
         LD4L::OreRDF::AddAggregatedResource.call( @aggregation,'http://example.org/resource_3')]
      end

      it 'should return a solr doc with all fields' do
        object_profile = /{\"id\":\"http:\/\/example.org\/moomin\",\"title\":\[\"My Resources\"\],\"description\":\[\"Resources that I like\"\],\"owner\":\"http:\/\/example.org\/person1\",\"aggregates\":\[\"http:\/\/example.org\/resource_[123]\",\"http:\/\/example.org\/resource_[123]\",\"http:\/\/example.org\/resource_[123]\"\],\"first_proxy_\":\"#{Regexp.quote(proxies.first.id)}\",\"last_proxy_\":\"#{Regexp.quote(proxies.last.id)}\"}/
        proxy_ids = proxies.collect { |p| p.id }

        solr_doc = @aggregation.aggregation_resource.generate_solr_document(@aggregation.proxy_resources).to_hash
        expect(solr_doc[:id]).to eq "http://example.org/moomin"
        expect(solr_doc[:at_model_ssi]).to eq "LD4L::OreRDF::AggregationResource"
        expect(solr_doc[:title_ti]).to eq "My Resources"
        expect(solr_doc[:title_ssort]).to eq "My Resources"
        expect(solr_doc[:description_ti]).to eq "Resources that I like"
        expect(solr_doc[:owner_ssi]).to eq "http://example.org/person1"
        expect(solr_doc[:aggregates_tsim]).to match_array ["http://example.org/resource_1", "http://example.org/resource_2", "http://example.org/resource_3"]
        expect(solr_doc[:item_proxies_ssm]).to match_array proxy_ids
        expect(solr_doc[:object_profile_ss]).to match object_profile
      end
    end

    context 'when aggregation has no owner' do
      xit 'should return without owner information' do
        pending 'this needs to be implemented'
      end
    end

    context 'when aggregation has owner' do
      xit 'should return with owner information' do
        pending 'this needs to be implemented'
      end
    end
  end

  ########### NEED TO MOVE TO SERVICE OBJECT ####################


  describe "#get_items_content" do
    context "when collection has 0 items" do
      before do
        subject.aggregates = []
      end
      it "should return empty array when no items exist" do
        subject.aggregates = []
        content_array = subject.get_items_content
        expect(content_array).to eq []
      end
    end

    context "when collection has items" do
      xit "should return array" do


        ###  TODO need to update add_items_with_content to use new service


        # subject.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
        #                                 RDF::URI("http://example.org/individual/b2"),
        #                                 RDF::URI("http://example.org/individual/b3")])




        content_array = subject.get_items_content
        expect(content_array).to be_a(Array)
      end
    end

    context "when start and limit are not specified" do
      xit "should return array of all content aggregated by subject" do


        ###  TODO need to update add_items_with_content to use new service


        # subject.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
        #                                 RDF::URI("http://example.org/individual/b2"),
        #                                 RDF::URI("http://example.org/individual/b3")])




        content_array = subject.get_items_content
        expect(content_array).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b1"))
        expect(content_array).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b2"))
        expect(content_array).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b3"))
      end

      xit "should not return any content not aggregated by subject" do
        vc = LD4L::OreRDF::AggregationResource.new('999')


        ###  TODO need to update add_items_with_content to use new service


        # vc.add_item_with_content(RDF::URI("http://example.org/individual/b999"))
        #
        # subject.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
        #                                 RDF::URI("http://example.org/individual/b2"),
        #                                 RDF::URI("http://example.org/individual/b3")])



        content_array = subject.get_items_content
        expect(content_array).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b1"))
        expect(content_array).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b2"))
        expect(content_array).to include ActiveTriples::Resource.new(RDF::URI("http://example.org/individual/b3"))
        expect(content_array.size).to eq 3
      end
    end

    context "when limit is specified" do
      xit "should return array of content with max size=limit" do
        pending "this needs to be implemented"
      end
    end

    context "when start is specified" do
      xit "should return array of content_beginning with item at position=start" do
        # TODO: What does _start_ mean in ActiveTriples?  Does it support this kind of query?
        pending "this needs to be implemented"
      end
    end

    context "when start and limit are specified" do
      xit "should return an array of content with max size=limit beginning with item at position=start" do
        pending "this needs to be implemented"
      end
    end
  end

  describe "#get_items" do
    context "when collection has 0 items" do
      before do
        subject.aggregates = []
      end

      it "should return empty array when no items exist" do
        vci_array = subject.get_items
        expect(vci_array).to eq []
      end
    end

    context "when collection has items" do
      before do


        ###  TODO need to update add_items_with_content to use new service


        # subject.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
        #                                 RDF::URI("http://example.org/individual/b2"),
        #                                 RDF::URI("http://example.org/individual/b3")])
      end

      xit "should return array" do
        vci_array = subject.get_items
        expect(vci_array).to be_a(Array)
      end

      xit "should return array of LD4L::OreRDF::ProxyResource instances" do
        vci_array = subject.get_items
        vci_array.each do |vci|
          expect(vci).to be_a(LD4L::OreRDF::ProxyResource)
        end
      end
    end

    context "when start and limit are not specified" do
      context "and objects not persisted" do
        xit "should return empty array" do


          ###  TODO need to update add_items_with_content to use new service


          # subject.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
          #                                 RDF::URI("http://example.org/individual/b2"),
          #                                 RDF::URI("http://example.org/individual/b3")])
          vci_array = subject.get_items
          expect(vci_array.size).to eq(0)
        end
      end

      context "and objects are persisted" do
        xit "should return array of all LD4L::OreRDF::ProxyResource instances for content aggregated by subject" do


          ###  TODO need to update add_items_with_content to use new service


          # vci_array = subject.add_items_with_content([RDF::URI("http://example.org/individual/b1"),
          #                                 RDF::URI("http://example.org/individual/b2"),
          #                                 RDF::URI("http://example.org/individual/b3")])
          subject.persist!
          vci_array.each { |vci| vci.persist! }

          vci_array = subject.get_items
          vci_array.each do |vci|
            expect(vci).to be_a(LD4L::OreRDF::ProxyResource)
            expect(vci.proxy_in_.first).to eq subject
          end
          results = []
          vci_array.each { |vci| results << vci.proxy_for_.first }
          expect(results).to match_array ["http://example.org/individual/b1","http://example.org/individual/b2","http://example.org/individual/b3"]
          expect(vci_array.size).to eq(3)
        end

        xit "should not return any LD4L::OreRDF::ProxyResource instances for content not aggregated by subject" do
          pending "this needs to be implemented"
        end
      end
    end

    context "when limit is specified" do
      xit "should return array of LD4L::OreRDF::ProxyResource instances with max size=limit" do
        pending "this needs to be implemented"
      end
    end

    context "when start is specified" do
      xit "should return array of LD4L::OreRDF::ProxyResource instances_beginning with item at position=start" do
        # TODO: What does _start_ mean in ActiveTriples?  Does it support this kind of query?
        pending "this needs to be implemented"
      end
    end

    context "when start and limit are specified" do
      xit "should return an array of LD4L::OreRDF::ProxyResource instances with max size=limit beginning with item at position=start" do
        pending "this needs to be implemented"
      end
    end
  end

  describe "#find_item_with_content" do
    skip "this needs to be implemented"
  end

  describe "#get_item_content_at" do
    skip "this needs to be implemented"
  end

  describe "#get_item_at" do
    skip "this needs to be implemented"
  end

  describe "#has_item_at?" do
    skip "this needs to be implemented"
  end

  describe "#has_item_content?" do
    skip "this needs to be implemented"
  end

  describe "#remove_item_with_content" do
    skip "this needs to be implemented"
  end

  describe "#is_ordered?" do
    skip "this needs to be implemented"
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
          subject.title = "bla"
          subject.persist!
        end

        it "should return true" do
          expect(subject).to be_persisted
        end

        context "and then modified" do
          before do
            subject.title = "newbla"
          end

          it "should return true" do
            expect(subject).to be_persisted
          end
        end
        context "and then reloaded" do
          before do
            subject.reload
          end

          it "should reset the title" do
            expect(subject.title).to eq ["bla"]
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

        subject {LD4L::OreRDF::AggregationResource.new("123")}
        let(:result) { subject.persist! }

        before do
          # Create inmemory repository
          @repo = RDF::Repository.new
          ActiveTriples::Repositories.repositories[:default] = @repo
          subject.title = "bla"
          result
        end

        it "should return true" do
          expect(result).to eq true
        end

        it "should persist to the repository" do
          expect(@repo.statements.first).to eq subject.statements.first
        end

        it "should delete from the repository" do
          subject.reload
          expect(subject.title).to eq ["bla"]
          subject.title = []
          expect(subject.title).to eq []
          subject.persist!
          subject.reload
          expect(subject.title).to eq []
          expect(@repo.statements.to_a.length).to eq 1 # Only the type statement
        end
      end
    end
  end

  describe '#destroy!' do
    before do
      subject << RDF::Statement(RDF::Vocab::DC.LicenseDocument, RDF::Vocab::DC.title, 'LICENSE')
    end

    subject { LD4L::OreRDF::AggregationResource.new('123') }

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
        subject.owner = child
      end

      let(:child) do
        if subject.respond_to? 'persistence_strategy'   # >= ActiveTriples 0.8
          LD4L::FoafRDF::Person.new('456',subject)
        else  # < ActiveTriples 0.8
          LD4L::FoafRDF::Person.new('456')
        end
      end

      it 'should empty the graph and remove it from the parent' do
        child.destroy
        expect(subject.owner).to be_empty
      end

      it 'should remove its whole graph from the parent' do
        child.destroy
        child.each_statement do |s|
          expect(subject.statements).not_to include s
        end
      end
    end
  end

  describe 'attributes' do
    before do
      subject.owner = owner
      subject.title = 'My Title'
    end

    subject {LD4L::OreRDF::AggregationResource.new("123")}

    let(:owner) { LD4L::FoafRDF::Person.new('456') }

    it 'should return an attributes hash' do
      expect(subject.attributes).to be_a Hash
    end

    it 'should contain data' do
      expect(subject.attributes['title']).to eq ['My Title']
    end

    it 'should contain child objects' do
      expect(subject.attributes['owner']).to eq [owner]
    end

    context 'with unmodeled data' do
      before do
        subject << RDF::Statement(subject.rdf_subject, RDF::Vocab::DC.contributor, 'Tove Jansson')
        subject << RDF::Statement(subject.rdf_subject, RDF::Vocab::DC.relation, RDF::URI('http://example.org/moomi'))
        node = RDF::Node.new
        subject << RDF::Statement(RDF::URI('http://example.org/moomi'), RDF::Vocab::DC.relation, node)
        subject << RDF::Statement(node, RDF::Vocab::DC.title, 'bnode')
      end

      it 'should include data with URIs as attribute names' do
        expect(subject.attributes[RDF::Vocab::DC.contributor.to_s]).to eq ['Tove Jansson']
      end

      it 'should return generic Resources' do
        expect(subject.attributes[RDF::Vocab::DC.relation.to_s].first).to be_a ActiveTriples::Resource
      end

      it 'should build deep data for Resources' do
        expect(subject.attributes[RDF::Vocab::DC.relation.to_s].first.get_values(RDF::Vocab::DC.relation).
                   first.get_values(RDF::Vocab::DC.title)).to eq ['bnode']
      end

      it 'should include deep data in serializable_hash' do
        expect(subject.serializable_hash[RDF::Vocab::DC.relation.to_s].first.get_values(RDF::Vocab::DC.relation).
                   first.get_values(RDF::Vocab::DC.title)).to eq ['bnode']
      end
    end

    describe 'attribute_serialization' do
      describe '#to_json' do
        it 'should return a string with correct objects' do
          json_hash = JSON.parse(subject.to_json)
          expect(json_hash['owner'].first['id']).to eq owner.rdf_subject.to_s
        end
      end
    end
  end

  describe 'property methods' do
    it 'should set and get properties' do
      subject.title = 'Comet in Moominland'
      expect(subject.title).to eq ['Comet in Moominland']
    end
  end

  describe 'child nodes' do
    it 'should return an object of the correct class when the value is built from the base URI' do
      subject.owner = LD4L::FoafRDF::Person.new('456')
      expect(subject.owner.first).to be_kind_of LD4L::FoafRDF::Person
    end

    it 'should return an object with the correct URI created with a URI' do
      subject.owner = LD4L::FoafRDF::Person.new("http://vivo.cornell.edu/individual/JohnSmith")
      expect(subject.owner.first.rdf_subject).to eq RDF::URI("http://vivo.cornell.edu/individual/JohnSmith")
    end

    it 'should return an object of the correct class when the value is a bnode' do
      subject.owner = LD4L::FoafRDF::Person.new
      expect(subject.owner.first).to be_kind_of LD4L::FoafRDF::Person
    end
  end

  describe '#set_value' do
    it 'should set a value in the graph' do
      subject.set_value(RDF::Vocab::DC.title, 'Comet in Moominland')
      subject.query(:subject => subject.rdf_subject, :predicate => RDF::Vocab::DC.title).each_statement do |s|
        expect(s.object.to_s).to eq 'Comet in Moominland'
      end
    end

    it 'should set a value in the when given a registered property symbol' do
      subject.set_value(:title, 'Comet in Moominland')
      expect(subject.title).to eq ['Comet in Moominland']
    end

    it "raise an error if the value is not a URI, Node, Literal, RdfResource, or string" do
      if subject.respond_to? 'persistence_strategy' # >= ActiveTriples 0.8
        error_name = ActiveTriples::Relation::ValueError
      else # < ActiveTriples 0.8
        error_name = RuntimeError
      end
      expect{subject.set_value(RDF::Vocab::DC.title, Object.new)}.to raise_error(error_name,/value must be an RDF URI, Node, Literal, or a valid datatype. See RDF::Literal.*/)
    end

    it "should be able to accept a subject" do
      expect{subject.set_value(RDF::URI("http://opaquenamespace.org/jokes"), RDF::Vocab::DC.title, 'Comet in Moominland')}.not_to raise_error
      expect(subject.query(:subject => RDF::URI("http://opaquenamespace.org/jokes"), :predicate => RDF::Vocab::DC.title).statements.to_a.length).to eq 1
    end
  end
  describe '#get_values' do
    before do
      subject.title = ['Comet in Moominland', "Finn Family Moomintroll"]
    end

    it 'should return values for a predicate uri' do
      expect(subject.get_values(RDF::Vocab::DC.title)).to match_array ['Comet in Moominland', 'Finn Family Moomintroll']
    end

    it 'should return values for a registered predicate symbol' do
      expect(subject.get_values(:title)).to match_array ['Comet in Moominland', 'Finn Family Moomintroll']
    end

    it "should return values for other subjects if asked" do
      expect(subject.get_values(RDF::URI("http://opaquenamespace.org/jokes"),:title)).to eq []
      subject.set_value(RDF::URI("http://opaquenamespace.org/jokes"), RDF::Vocab::DC.title, 'Comet in Moominland')
      expect(subject.get_values(RDF::URI("http://opaquenamespace.org/jokes"),:title)).to eq ["Comet in Moominland"]
    end
  end

  describe '#type' do
    it 'should return the type configured on the parent class' do
      expected_result = LD4L::OreRDF::AggregationResource.type.kind_of?(Array) ? LD4L::OreRDF::AggregationResource.type : [LD4L::OreRDF::AggregationResource.type]
      expect(subject.type).to eq expected_result
    end

    it 'should set the type' do
      subject.type = RDF::URI('http://example.org/AnotherClass')
      expect(subject.type).to eq [RDF::URI('http://example.org/AnotherClass')]
    end

    it 'should be the type in the graph' do
      subject.query(:subject => subject.rdf_subject, :predicate => RDF.type).statements do |s|
        expect(s.object).to eq RDF::URI('http://example.org/AnotherClass')
      end
    end
  end

  describe '#rdf_label' do
    it 'should return an array of label values' do
      expect(subject.rdf_label).to be_kind_of Array
    end

    it 'should return the default label values' do
      subject.title = 'Comet in Moominland'
      expect(subject.rdf_label).to eq ['Comet in Moominland']
    end

    it 'should prioritize configured label values' do
      custom_label = RDF::URI('http://example.org/custom_label')
      subject.class.configure :rdf_label => custom_label
      subject << RDF::Statement(subject.rdf_subject, custom_label, RDF::Literal('New Label'))
      subject.title = 'Comet in Moominland'
      expect(subject.rdf_label).to eq ['New Label']
    end
  end

  describe 'editing the graph' do
    it 'should write properties when statements are added' do
      subject << RDF::Statement.new(subject.rdf_subject, RDF::Vocab::DC.title, 'Comet in Moominland')
      expect(subject.title).to include 'Comet in Moominland'
    end

    it 'should delete properties when statements are removed' do
      subject << RDF::Statement.new(subject.rdf_subject, RDF::Vocab::DC.title, 'Comet in Moominland')
      subject.delete RDF::Statement.new(subject.rdf_subject, RDF::Vocab::DC.title, 'Comet in Moominland')
      expect(subject.title).to eq []
    end
  end

  describe 'big complex graphs' do
    before do
      class DummyPerson < ActiveTriples::Resource
        configure :type => RDF::URI('http://example.org/Person')
        property :foafname, :predicate => RDF::Vocab::FOAF.name
        property :publications, :predicate => RDF::Vocab::FOAF.publications, :class_name => 'DummyDocument'
        property :knows, :predicate => RDF::Vocab::FOAF.knows, :class_name => DummyPerson
      end

      class DummyDocument < ActiveTriples::Resource
        configure :type => RDF::URI('http://example.org/Document')
        property :title, :predicate => RDF::Vocab::DC.title
        property :creator, :predicate => RDF::Vocab::DC.creator, :class_name => 'DummyPerson'
      end

      LD4L::OreRDF::AggregationResource.property :item, :predicate => RDF::Vocab::DC.relation, :class_name => DummyDocument
    end

    subject { LD4L::OreRDF::AggregationResource.new }

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
      person2.knows = person1
      subject.item = [document1]
      expect(subject.item.first.creator.first.knows.first.foafname)
          .to satisfy { |names| ['Alice', 'Bob'].include? names.first }
    end
  end
end
