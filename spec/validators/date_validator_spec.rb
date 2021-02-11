RSpec.describe MetadataPresenter::DateValidator do
  subject(:validator) do
    described_class.new(page_answers: page_answers, component: component)
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  describe '#valid?' do
    let(:page) { service.find_page_by_url('/holiday') }
    let(:answers) do
      {
        'holiday_date_1(3i)' => day,
        'holiday_date_1(2i)' => month,
        'holiday_date_1(1i)' => year
      }
    end

    before do
      validator.valid?
    end

    context 'when answer is nil' do
      let(:day) { nil }
      let(:month) { nil }
      let(:year) { nil }

      it 'returns valid allowing blanks' do
        expect(validator).to be_valid
      end
    end

    context 'when answer is empty' do
      let(:day) { '' }
      let(:month) { '' }
      let(:year) { '' }

      it 'returns valid allowing blanks' do
        expect(validator).to be_valid
      end
    end

    context 'when answer is partially empty' do
      let(:day) { '10' }
      let(:month) { '' }
      let(:year) { '' }

      it 'returns valid allowing blanks' do
        expect(validator).to be_valid
      end
    end

    context 'when answer is invalid' do
      context 'when invalid day' do
        let(:day) { '32' }
        let(:month) { '12' }
        let(:year) { '2020' }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end
      end

      context 'when invalid month' do
        let(:day) { '04' }
        let(:month) { '13' }
        let(:year) { '2020' }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end
      end

      context 'when invalid year' do
        let(:day) { '04' }
        let(:month) { '13' }
        let(:year) { 'xxxx' }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end
      end

      context 'when answer has invalid day format' do
        let(:day) { 'abcdef' }
        let(:month) { '12' }
        let(:year) { '2020' }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end
      end

      context 'when answer has invalid year format' do
        let(:day) { '01' }
        let(:month) { '12' }
        let(:year) { 'def' }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end
      end
    end

    context 'when answer is valid' do
      let(:day) { '04' }
      let(:month) { '12' }
      let(:year) { '2020' }

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end
  end
end
