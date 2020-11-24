require 'rails_helper'

RSpec.describe MetadataPresenter::Page do
  let(:service_metadata) do
    JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'service.json')))
  end

  context 'when creating a new service object' do
    let(:service) { MetadataPresenter::Service.new(service_metadata) }

    it '#components should return an array of Component objects' do
    components = service.pages.map(&:components).flatten.compact
      components.each do |component|
        expect(component).to be_kind_of(MetadataPresenter::Component)
      end
    end
  end
end
