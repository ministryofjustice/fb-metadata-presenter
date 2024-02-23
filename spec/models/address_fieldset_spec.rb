RSpec.describe MetadataPresenter::AddressFieldset do
  subject(:address_fieldset) { described_class.new(metadata) }

  let(:metadata) do
    {
      'address_line_one' => '1 road',
      'address_line_two' => '',
      'city' => 'ruby town',
      'county' => '',
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

  describe '#as_json' do
    it 'returns a json representation of the address' do
      expect(
        subject.as_json
      ).to eq(metadata)
    end

    it 'has the json keys ordered' do
      expect(subject.as_json.keys).to eq(
        %w[address_line_one address_line_two city county postcode country]
      )
    end
  end
end
