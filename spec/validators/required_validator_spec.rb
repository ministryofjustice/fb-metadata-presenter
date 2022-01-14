RSpec.describe MetadataPresenter::RequiredValidator do
  subject(:validator) do
    described_class.new(page_answers: page_answers, component: component)
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  describe '#valid?' do
    before do
      validator.valid?
    end

    context 'when there is required validations on the metadata' do
      context 'when there is no custom error message' do
        let(:page) { service.find_page_by_url('/name') }
        let(:answers) { {} }

        it 'be invalid' do
          expect(validator).to_not be_valid
        end

        it 'set default error message on page' do
          expect(page_answers.errors.full_messages).to eq(
            ['Enter an answer for Full name']
          )
        end
      end

      context 'when there is custom error message' do
        context 'when there is "any"' do
          let(:page) { service.find_page_by_url('/parent-name') }
          let(:answers) { { 'parent-name_text_1' => '' } }

          it 'be invalid' do
            expect(validator).to_not be_valid
          end

          it 'set default error message on page' do
            expect(page_answers.errors.full_messages).to eq(
              ['Enter a parent name']
            )
          end
        end
      end

      context 'when required is valid' do
        let(:answers) { { 'name_text_1' => 'Gandalf' } }
        let(:page) { service.find_page_by_url('/name') }

        it 'returns no errors' do
          expect(page_answers.errors.full_messages).to eq([])
        end
      end

      context 'when checkbox' do
        let(:page) { service.find_page_by_url('/burgers') }
        let(:answers) { { 'burgers_checkbox_1' => [''] } }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end
      end

      context 'when date field' do
        let(:page) { service.find_page_by_url('/holiday') }
        let(:answers) do
          {
            'holiday_date_1(3i)' => day,
            'holiday_date_1(2i)' => month,
            'holiday_date_1(1i)' => year
          }
        end

        context 'when date is nil' do
          let(:day) { nil }
          let(:month) { '10' }
          let(:year) { '2020' }

          it 'returns invalid' do
            expect(validator).to_not be_valid
          end

          it 'returns errors' do
            validator.valid?
            expect(page_answers.errors[:holiday_date_1]).to include(
              'Enter an answer for What is the day that you like to take holidays?'
            )
          end
        end

        context 'when date is present' do
          let(:day) { '1' }
          let(:month) { '10' }
          let(:year) { '2020' }

          it 'returns valid' do
            expect(validator).to be_valid
          end
        end
      end
    end
  end
end
