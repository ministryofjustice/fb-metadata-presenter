RSpec.describe MetadataPresenter::Item do
  subject(:item) { described_class.new(metadata) }

  describe '#id' do
    let(:metadata) do
      {
        '_id' => 'some-id',
        'label' => 'Some label'
      }
    end

    it 'returns the id' do
      expect(item.id).to eq('some-id')
    end
  end

  describe '#name' do
    let(:metadata) { { 'label' => 'Some label' } }

    it 'returns label' do
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
