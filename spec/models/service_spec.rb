require 'rails_helper'

RSpec.describe MetadataPresenter::Service do
  let(:service_metadata) do
    JSON.parse(
      File.read(
        MetadataPresenter::Engine.root.join('spec', 'fixtures', 'service.json')
      )
    )
  end
  let(:service) { MetadataPresenter::Service.new(service_metadata) }

  describe '#pages' do
    it 'returns an array of Page objects' do
      service.pages.each do |page|
        expect(page).to be_kind_of(MetadataPresenter::Page)
      end
    end
  end

  describe '#find_page' do
    it 'finds the correct page' do
      path = service_metadata['pages'][1]['url']
      page = service.find_page(path)
      expect(page.id).to eq(service_metadata['pages'][1]['_id'])
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
end
