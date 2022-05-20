RSpec.describe MetadataPresenter::DateBeforeValidator do
  subject(:validator) do
    described_class.new(page_answers: page_answers, component: component)
  end
  let(:page) do
    meta = service.find_page_by_url('/holiday')
    meta['components'][0]['validation'] = date_before_validation
    meta
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }
  let(:date_before_validation) { { 'date_before' => '1955-11-05' } }

  describe '#validate' do
    before do
      validator.valid?
    end

    context 'when date is before the latest date' do
      let(:answers) do
        {
          'holiday_date_1(3i)' => '1',
          'holiday_date_1(2i)' => '1',
          'holiday_date_1(1i)' => '1955'
        }
      end

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end

    context 'when date is after the latest date' do
      let(:answers) do
        {
          'holiday_date_1(3i)' => '1',
          'holiday_date_1(2i)' => '1',
          'holiday_date_1(1i)' => '2055'
        }
      end

      it 'returns invalid' do
        expect(validator).to_not be_valid
      end
    end

    context 'when not a valid date' do
      let(:answers) do
        {
          'holiday_date_1(3i)' => '1',
          'holiday_date_1(2i)' => '1',
          'holiday_date_1(1i)' => 'not a year'
        }
      end

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end
  end
end
