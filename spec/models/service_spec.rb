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
        'service_name' => 'Service name'
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
      let(:uuid) { 'fa391697-ae82-4416-adc3-3433e54ce535' }

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
      let(:uuid) { '67c91f95-805e-4731-969e-648c7d3d172f' }

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

  describe '#previous_page' do
    context 'when previous page exists' do
      it 'returns the previous page' do
        current_page = service.find_page_by_url(service_metadata['pages'][1]['url'])
        previous_page = service.previous_page(
          current_page: current_page,
          referrer: 'https://example.com'
        )
        expect(previous_page.id).to eq(service_metadata['pages'][0]['_id'])
      end
    end

    context 'when previous page does not exists' do
      it 'returns nil' do
        current_page = service.find_page_by_url(service_metadata['pages'][0]['url']) # start page
        previous_page = service.previous_page(
          current_page: current_page, referrer: nil)
        expect(previous_page).to be(nil)
      end
    end

    context 'when current page is not part of the standard page flow' do
      it 'finds the previous page by referrer' do
        current_page = service.find_page_by_url('/cookies')
        previous_page = service.previous_page(
          current_page: current_page,
          referrer: service.start_page.url
        )
        expect(previous_page.id).to eq(service.start_page.id)
      end
    end

    context 'when there is no referrer page' do
      it 'returns nil' do
        previous_page = service.previous_page(current_page: nil, referrer: nil)
        expect(previous_page).to be_nil
      end
    end

    context 'when current page is confirmation page' do
      it 'returns nil' do
        confirmation_page = service.pages.find { |page| page.type == 'page.confirmation' }
        # just in case the confirmation page gets removed from the fixture accidentally
        expect(confirmation_page).to be_truthy

        previous_page = service.previous_page(
          current_page: confirmation_page,
          referrer: nil
        )
        expect(previous_page).to be_nil
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
end
