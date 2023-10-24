require 'rails_helper'

RSpec.describe MetadataPresenter::Service do
  describe '#service_slug' do
    let(:service_names) do
      {
        'grogu' => 'grogu',
        'Darth Vader' => 'darth-vader',
        'emperor-palpatine' => 'emperor-palpatine',
        'princess Leia' => 'princess-leia',
        "Darth Vader Children's" => 'darth-vader-childrens',
        'Darth Vader Children’s' => 'darth-vader-childrens'
      }
    end

    it 'returns the name parameterized' do
      service_names.each do |service_name, expected|
        expect(
          described_class.new(
            { 'service_name' => service_name }
          ).service_slug
        ).to eq(expected)
      end
    end
  end

  describe '#to_json' do
    it 'returns json object' do
      expect(JSON.parse(service.to_json)).to include(
        'service_name' => 'Version Fixture'
      )
    end
  end

  describe '#pages' do
    it 'returns an array of Page objects' do
      service.pages.each do |page|
        expect(page).to be_kind_of(MetadataPresenter::Page)
      end
    end
  end

  describe '#branches' do
    let(:service) do
      MetadataPresenter::Service.new(metadata_fixture(:branching))
    end

    it 'returns an array of Flow objects' do
      expect(service.branches.size).to be > 1
      service.branches.each do |flow|
        expect(flow.type).to eq('flow.branch')
      end
    end
  end

  describe '#flow_objects' do
    it 'returns the service flow as Flow objects' do
      service.branches.each do |flow|
        expect(flow).to be_kind_of(MetadataPresenter::Flow)
      end
    end
  end

  describe '#expressions' do
    let(:service_metadata) { metadata_fixture(:branching_2) }

    it 'returns all expressions in the flow' do
      expect(service.expressions.size).to be(3)

      service.expressions.each do |expression|
        expect(expression).to be_kind_of(MetadataPresenter::Expression)
      end
    end
  end

  describe '#conditionals' do
    let(:service_metadata) { metadata_fixture(:branching_3) }

    it 'returns all conditionals in the flow' do
      expect(service.conditionals.size).to be(2)

      service.conditionals.each do |conditional|
        expect(conditional).to be_kind_of(MetadataPresenter::Conditional)
      end
    end
  end

  describe '#content_expressions' do
    let(:service_metadata) { metadata_fixture(:conditional_content) }

    it 'returns all content expressions' do
      expect(service.content_expressions.size).to be(15)

      service.content_expressions.each do |expression|
        expect(expression).to be_kind_of(MetadataPresenter::Expression)
      end
    end
  end

  describe '#find_page_by_url' do
    subject(:page) { service.find_page_by_url(path) }

    context 'when passing without slash in the beginning' do
      let(:path) { 'name' }

      it 'finds the correct page' do
        expect(page.id).to eq(service_metadata['pages'][1]['_id'])
      end
    end

    context 'when passing with slash in the beginning' do
      let(:path) { '/name' }

      it 'finds the correct page' do
        expect(page.id).to eq(service_metadata['pages'][1]['_id'])
      end
    end

    context 'when page does not exist' do
      let(:path) do
        '/darth-vader-nooooooooo'
      end

      it 'returns nil' do
        expect(page).to be_nil
      end
    end

    context 'standalone pages' do
      let(:path) { '/cookies' }

      it 'finds the correct page' do
        expect(page.id).to eq('page.cookies')
      end
    end
  end

  describe '#find_page_by_uuid' do
    subject(:page) { service.find_page_by_uuid(uuid) }

    context 'when uuid exists' do
      let(:uuid) { 'cf6dc32f-502c-4215-8c27-1151a45735bb' }

      it 'finds the correct page' do
        expect(page.id).to eq(service_metadata['pages'][0]['_id'])
      end
    end

    context 'when uuid does not exist in metadata' do
      let(:uuid) { SecureRandom.uuid }

      it 'returns nil' do
        expect(page).to be_nil
      end
    end

    context 'when standalone pages' do
      let(:uuid) { 'c439c7fd-f411-4e11-8598-4023934bac93' }

      it 'finds the correct page' do
        expect(page.id).to eq('page.accessibility')
      end
    end
  end

  describe '#start_page' do
    let(:service) do
      meta = metadata_fixture(:branching)
      meta['pages'] = meta['pages'].shuffle
      MetadataPresenter::Service.new(meta)
    end

    it 'returns the correct start page' do
      expect(service.start_page.type).to eq('page.start')
      expect(service.start_page.url).to eq('/')
    end
  end

  describe '#next_page' do
    context 'when next page exists' do
      it 'returns the next page' do
        path = service_metadata['pages'][1]['url']
        page = service.next_page(from: path)
        expect(page.id).to eq(service_metadata['pages'][2]['_id'])
      end
    end

    context 'when current page does not exists' do
      it 'returns nil' do
        page = service.next_page(from: 'path-that-doesnot-exist')
        expect(page).to be(nil)
      end
    end

    context 'when next page does not exists' do
      it 'returns nil' do
        path = service_metadata['pages'][-1]['url']
        page = service.next_page(from: path)
        expect(page).to be(nil)
      end
    end
  end

  describe '#confirmation_page' do
    it 'returns the confirmation page for the service' do
      expect(service.confirmation_page.type).to eq('page.confirmation')
    end
  end

  describe '#checkanswers_page' do
    it 'returns the check answers page for the service' do
      expect(service.checkanswers_page.type).to eq('page.checkanswers')
    end
  end

  describe '#meta' do
    it 'returns a meta object' do
      expect(service.meta).to be_kind_of(MetadataPresenter::Meta)
    end
  end

  describe '#no_back_link' do
    let(:start_page) { service.start_page }
    let(:confirmation_page) { service.confirmation_page }
    let(:checkanswers_page) { service.checkanswers_page }

    it 'returns true for start page' do
      expect(service.no_back_link?(start_page)).to be true
    end

    it 'returns true for confirmation page' do
      expect(service.no_back_link?(confirmation_page)).to be true
    end

    it 'returns true for standalone pages' do
      service.standalone_pages.each do |page|
        expect(service.no_back_link?(page)).to be true
      end
    end

    it 'returns false for other pages' do
      expect(service.no_back_link?(checkanswers_page)).to be false
    end
  end

  describe '#page_with_component' do
    let(:page) { service.find_page_by_url('do-you-like-star-wars') }
    let(:component_uuid) { page.components.first.uuid }

    it 'returns the correct page containing the component' do
      expect(service.page_with_component(component_uuid)).to eq(page)
    end
  end

  describe '#pages_with_conditional_content_for_page' do
    let(:service_metadata) { metadata_fixture(:conditional_content_2) }
    let(:page) { 'fa925598-c4b9-4494-a42b-01ed5390ad7d' }
    let(:subject) { service.pages_with_conditional_content_for_page(page) }

    it 'returns the pages that use the uuid in content conditionals' do
      expect(subject.size).to eq(1)

      expect(subject.map(&:_uuid)).to eq(%w[bb72a6a3-5f75-4874-90c3-ac7a6b83e9e5])
    end
  end

  describe '#pages_with_conditional_content_for_question' do
    let(:service_metadata) { metadata_fixture(:conditional_content_2) }
    let(:question) { '37bc88a2-26c9-42c7-a4b4-3803a4a313a1' }
    let(:subject) { service.pages_with_conditional_content_for_question(question) }

    it 'returns the pages that use the uuid in content conditionals' do
      expect(subject.size).to eq(1)

      expect(subject.map(&:_uuid)).to eq(%w[88ce3bb5-bd9f-493b-85c5-d2e93466415e])
    end
  end

  describe '#pages_with_conditional_content_for_question_option' do
    let(:service_metadata) { metadata_fixture(:conditional_content_2) }
    let(:question_option) { 'f1443897-cf2f-401b-ac97-41711a8f9388' }
    let(:subject) { service.pages_with_conditional_content_for_question_option(question_option) }

    it 'returns the pages that use the uuid in content conditionals' do
      expect(subject.size).to eq(1)

      expect(subject.map(&:_uuid)).to eq(%w[88ce3bb5-bd9f-493b-85c5-d2e93466415e])
    end
  end
end
