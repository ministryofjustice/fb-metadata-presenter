RSpec.describe MetadataPresenter::DateAfterValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end
  let(:page) do
    meta = service.find_page_by_url('/holiday')
    meta['components'][0]['validation'] = date_after_validation
    meta
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }
  let(:date_after_validation) { { 'date_after' => '1997-08-29' } }

  describe '#validate' do
    before do
      validator.valid?
    end

    context 'when date is after the earliest date' do
      let(:answers) do
        {
          'holiday_date_1(3i)' => '1',
          'holiday_date_1(2i)' => '1',
          'holiday_date_1(1i)' => '2055'
        }
      end

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end

    context 'when date is before the earliest date' do
      let(:answers) do
        {
          'holiday_date_1(3i)' => '1',
          'holiday_date_1(2i)' => '1',
          'holiday_date_1(1i)' => '1990'
        }
      end
      it 'returns invalid' do
        expect(validator).to_not be_valid
      end
    end

    context 'when not a valid date' do
      let(:answers) do
        {
          'holiday_date_1(3i)' => 'not a day',
          'holiday_date_1(2i)' => '1',
          'holiday_date_1(1i)' => '1999'
        }
      end

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end
  end

  describe '#validation_value' do
    let(:answers) do
      {
        'holiday_date_1(3i)' => '1',
        'holiday_date_1(2i)' => '1',
        'holiday_date_1(1i)' => '1999'
      }
    end
    let(:expected_formatted_date) { '29 08 1997' }

    it 'correctly formats the date validation configuration value' do
      expect(validator.validation_value).to eq(expected_formatted_date)
    end
  end
end
