require 'rails_helper'

RSpec.describe MetadataPresenter::Page do
  let(:service_metadata) do
    JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'service.json')))
  end

  describe '#==' do
    let(:page) { described_class.new(_id: 'foo') }

    context 'when two pages are equal' do
      let(:other_page) { described_class.new(_id: 'foo') }

      it 'returns true' do
        expect(page == other_page).to be_truthy
      end
    end

    context 'when two pages are different' do
      let(:other_page) { described_class.new(_id: 'foobar') }

      it 'returns false' do
        expect(page == other_page).to be_falsey
      end
    end

    context 'when comparing different objects' do
      let(:other_object) { true }

      it 'returns false' do
        expect(page == other_object).to be_falsey
      end
    end
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

  describe '#to_partial_path' do
    subject(:page) { described_class.new(_type: 'page.singlequestion') }

    it 'returns the type of the page' do
      expect(page.to_partial_path).to eq('page/singlequestion')
    end
  end
end
