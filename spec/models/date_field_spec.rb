RSpec.describe MetadataPresenter::DateField do
  subject(:date_field) do
    described_class.new(day: day, month: month, year: year)
  end

  describe '#present?' do
    context 'when all fields present' do
      let(:day) { '1' }
      let(:month) { '1' }
      let(:year) { '1' }

      it 'returns true' do
        expect(date_field).to be_present
      end
    end

    context 'when at least one field is not present' do
      let(:day) { '' }
      let(:month) { '1' }
      let(:year) { '1' }

      it 'returns false' do
        expect(date_field).to_not be_present
      end
    end
  end

  describe '#blank?' do
    context 'when all fields present' do
      let(:day) { '1' }
      let(:month) { '1' }
      let(:year) { '1' }

      it 'returns false' do
        expect(date_field).to_not be_blank
      end
    end

    context 'when at least one field is not present' do
      let(:day) { '' }
      let(:month) { '1' }
      let(:year) { '1' }

      it 'returns true' do
        expect(date_field).to be_blank
      end
    end
  end
end
