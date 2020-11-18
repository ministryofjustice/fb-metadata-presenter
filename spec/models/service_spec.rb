require 'rails_helper'

RSpec.describe MetadataPresenter::Service do
  let(:service_metadata) do
    JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'service.json')))
  end

  context 'when creating a new service object' do
    let(:service) { MetadataPresenter::Service.new(service_metadata) }

    it '#pages should return an array of Page objects' do
      service.pages.each do |page|
        expect(page).to be_kind_of(MetadataPresenter::Page)
      end
    end

    it 'returns the correct start page' do
      expect(service.start_page.id).to eq(service_metadata['pages'][0]['_id'])
    end
  end
end
