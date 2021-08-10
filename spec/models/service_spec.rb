require 'rails_helper'

RSpec.describe MetadataPresenter::Service do
  describe '#service_slug' do
    let(:service_names) do
      {
        'grogu' => 'grogu',
        'Darth Vader' => 'darth-vader',
        'emperor-palpatine' => 'emperor-palpatine',
        'princess Leia' => 'princess-leia'
      }
    end

    it 'returns the name parameterized' do
      service_names.each do |service_name, expected|
        expect(
          described_class.new(
            'service_name' => service_name
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
        expect(flow).to be_kind_of(MetadataPresenter::Flow)
        expect(flow.type).to eq('flow.branch')
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
    it 'returns the correct start page' do
      expect(service.start_page.id).to eq(service_metadata['pages'][0]['_id'])
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

  describe '#meta' do
    it 'returns a meta object' do
      expect(service.meta).to be_kind_of(MetadataPresenter::Meta)
    end
  end

  describe '#page_with_component' do
    let(:page) { service.find_page_by_url('do-you-like-star-wars') }
    let(:component_uuid) { page.components.first.uuid }

    it 'returns the correct page containing the component' do
      expect(service.page_with_component(component_uuid)).to eq(page)
    end
  end
end
