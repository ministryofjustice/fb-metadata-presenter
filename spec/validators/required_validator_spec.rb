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
        let(:answers) { { } }

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
          let(:page) { service.find_page_by_url('/email-address') }
          let(:answers) { { 'email-address_email_1' => '' } }

          it 'be invalid' do
            expect(validator).to_not be_valid
          end

          it 'set default error message on page' do
            expect(page_answers.errors.full_messages).to eq(
              ['Enter an email address']
            )
          end
        end
      end

      context 'when required is valid' do
        let(:answers) { {'name_text_1' => 'Gandalf' } }
        let(:page) { service.find_page_by_url('/name') }

        it 'returns no errors' do
          expect(page_answers.errors.full_messages).to eq([])
        end
      end
    end
  end
end
