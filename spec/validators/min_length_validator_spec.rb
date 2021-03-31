RSpec.describe MetadataPresenter::MinLengthValidator do
  subject(:validator) do
    described_class.new(page_answers: page_answers, component: component)
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  describe '#valid?' do
    before do
      validator.valid?
    end

    context 'when answer is blank' do
      let(:answers) { { 'name_text_1' => '' } }
      let(:page) { service.find_page_by_url('/name') }

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end

    context 'when minimum length is invalid' do
      let(:answers) { { 'name_text_1' => 'T' } }

      context 'when there is no custom error message' do
        let(:page) { service.find_page_by_url('/name') }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end

        it 'uses the default error message' do
          expect(page_answers.errors.full_messages).to eq(
            ["Your answer for 'Full name' is too short (2 characters at least)"]
          )
        end
      end

      context 'when there is a custom error message' do
        let(:page) { service.find_page_by_url('/email-address') }
        let(:answers) do
          { 'email-address_email_1' => 'g' }
        end

        it 'uses the custom error message' do
          expect(page_answers.errors.full_messages).to eq(
            ['Your email address is too short.']
          )
        end
      end
    end

    context 'when minimum length is valid' do
      let(:answers) { { 'name_text_1' => 'Gandalf' } }
      let(:page) { service.find_page_by_url('/name') }

      it 'returns no errors' do
        expect(page_answers.errors.full_messages).to eq([])
      end
    end
  end
end
