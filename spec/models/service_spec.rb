require 'rails_helper'

RSpec.describe MetadataPresenter::Service do
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

  describe '#previous_page' do
    context 'when previous page exists' do
      it 'returns the previous page' do
        current_page = service.find_page(service_metadata['pages'][1]['url'])
        previous_page = service.previous_page(current_page: current_page)
        expect(previous_page.id).to eq(service_metadata['pages'][0]['_id'])
      end
    end

    context 'when previous page does not exists' do
      it 'returns nil' do
        current_page = service.find_page(service_metadata['pages'][0]['url'])
        previous_page = service.previous_page(current_page: current_page)
        expect(previous_page).to be(nil)
      end
    end
  end
end
