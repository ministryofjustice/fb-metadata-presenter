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

  describe '.new' do
    context 'country' do
      let(:metadata) { super().merge('country' => nil) }

      it 'sets a default country if none was provided' do
        expect(subject.country).to eq(described_class::DEFAULT_COUNTRY)
      end
    end

    context 'sanitize and strip spaces from fields' do
      let(:metadata) do
        super().merge(
          {
            'city' => "<div> some tag <img src='test.jpg'>",
            'country' => '  UK   '
          }
        )
      end

      it 'removes the tags' do
        expect(subject.city).to eq('some tag')
      end

      it 'removes leading and trailing spaces' do
        expect(subject.country).to eq('UK')
      end
    end
  end

  describe '#to_a' do
    it 'returns a nice array to be shown in CYA page' do
      expect(subject.to_a).to eq(['1 road', 'ruby town', '99 999', 'ruby land'])
    end
  end
end
