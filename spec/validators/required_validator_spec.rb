RSpec.describe MetadataPresenter::RequiredValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  describe '#valid?' do
    let(:locale) { :en }

    before do
      I18n.with_locale(locale) { validator.valid? }
    end

    context 'when there is required validations on the metadata' do
      context 'when component is multiupload' do
        let(:page) { service.find_page_by_url('/dog-picture-2') }

        context 'when any file is present' do
          let(:answers) { { 'dog-picture_upload_2' => { 'original_filename' => 'cool-file.txt' } } }

          it 'returns valid' do
            expect(validator).to be_valid
          end
        end

        context 'when no file is present' do
          let(:answers) { { 'dog-picture_upload_2' => {} } }

          it 'returns invalid' do
            expect(validator).to_not be_valid
          end
        end
      end

      context 'when there is no custom error message' do
        let(:page) { service.find_page_by_url('/name') }
        let(:answers) { {} }

        it 'be invalid' do
          expect(validator).to_not be_valid
        end

        it 'set default error message on page' do
          expect(page_answers.errors.full_messages).to eq(
            ['Enter an answer for "Full name"']
          )
        end
      end

      context 'when there is custom error message defined on the locales' do
        let(:page) { service.find_page_by_url('/dog-picture-2') }
        let(:answers) { { 'dog-picture_upload_2' => {} } }

        it 'is invalid' do
          expect(validator).to_not be_valid
        end

        context 'for english locale' do
          it 'gets the error message from the locales' do
            expect(page_answers.errors.full_messages).to eq(
              ['Choose a file to upload']
            )
          end
        end

        context 'for welsh locale' do
          let(:locale) { :cy }

          it 'gets the error message from the locales' do
            expect(page_answers.errors.full_messages).to eq(
              ['(cy) Choose a file to upload']
            )
          end
        end
      end

      context 'when there is custom error message defined on the metadata' do
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

      context 'when locale is welsh' do
        let(:page) { service.find_page_by_url('/name') }
        let(:answers) { {} }
        let(:locale) { :cy }

        it 'is invalid' do
          expect(validator).to_not be_valid
        end

        it 'sets welsh error message on page' do
          expect(page_answers.errors.full_messages).to eq(
            ['Rhowch ateb i "Full name"']
          )
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
              'Enter an answer for "What is the day that you like to take holidays?"'
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

      context 'when component is an address' do
        let(:page) { service.find_page_by_url('/postal-address') }
        let(:answers) { { 'postal-address_address_1' => {} } }

        # NOTE: required fields validation performed in separate `AddressValidator`
        # For an address component this validator is always successful
        it 'is valid' do
          expect(validator).to be_valid
        end
      end
    end
  end
end
