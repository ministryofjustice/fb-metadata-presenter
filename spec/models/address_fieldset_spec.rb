RSpec.describe MetadataPresenter::AddressFieldset do
  subject(:address_fieldset) { described_class.new(metadata) }
  let(:metadata) do
    {
      'address_line_one' => '1 road',
      'city' => 'ruby town',
      'postcode' => '99 999',
      'country' => 'ruby land'
    }
  end

  describe '#to_a' do
    it 'returns a nice array to be shown in CYA page' do
      expect(subject.to_a).to eq(['1 road', 'ruby town', '99 999', 'ruby land'])
    end
  end

  describe '#strip' do
    it 'returns a nice string to be included in emails' do
      expect(subject.strip).to eq('1 road, ruby town, 99 999, ruby land')
    end
  end
end
