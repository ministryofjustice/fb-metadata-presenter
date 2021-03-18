RSpec.describe MetadataPresenter::Item do
  subject(:item) { described_class.new(metadata) }

  describe '#name' do
    let(:metadata) { { 'label' => 'Some label' } }

    it 'returns hint' do
      expect(item.name).to eq('Some label')
    end
  end

  describe '#description' do
    let(:metadata) { { 'hint' => 'Some hint' } }

    it 'returns hint' do
      expect(item.description).to eq('Some hint')
    end
  end
end
