RSpec.describe MetadataPresenter::AutocompleteItem do
  subject(:autocomplete_item) { described_class.new(metadata) }

  describe '#id' do
    let(:metadata) { { 'value' => 'some value' } }

    it 'returns the value property' do
      expect(subject.id).to eq('some value')
    end
  end

  describe '#name' do
    let(:metadata) { { 'text' => 'some text' } }

    it 'returns the name property' do
      expect(subject.name).to eq('some text')
    end
  end
end
