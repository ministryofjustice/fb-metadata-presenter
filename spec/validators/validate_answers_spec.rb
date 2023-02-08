RSpec.describe MetadataPresenter::ValidateAnswers do
  subject(:validate_answers) do
    described_class.new(page_answers, components: page.components, autocomplete_items:)
  end
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }
  let(:autocomplete_items) { {} }
  let(:page) { service.find_page_by_url('/name') }

  describe '#valid?' do
    context 'when is valid' do
      let(:answers) { { 'name_text_1' => 'Gandalf' } }

      it 'returns true' do
        expect(validate_answers).to be_valid
      end
    end

    context 'when validation required = false in metadata' do
      let(:page) { service.find_page_by_url('/parent-name') }

      context 'when no answer is provided' do
        let(:answers) { { 'parent-name_text_1' => '' } }

        it 'does not attempt any validations' do
          expect_any_instance_of(MetadataPresenter::RequiredValidator).not_to receive(:invalid_answer?)
          expect_any_instance_of(MetadataPresenter::MinLengthValidator).not_to receive(:invalid_answer?)
          expect_any_instance_of(MetadataPresenter::MaxLengthValidator).not_to receive(:invalid_answer?)
          expect(validate_answers).to be_valid
        end
      end

      context 'when an answer is provided' do
        let(:answers) { { 'parent-name_text_1' => 'Grogu' } }

        it 'should validate the answer' do
          expect_any_instance_of(MetadataPresenter::RequiredValidator).not_to receive(:invalid_answer?)
          expect_any_instance_of(MetadataPresenter::MinLengthValidator).to receive(:invalid_answer?)
          expect_any_instance_of(MetadataPresenter::MaxLengthValidator).to receive(:invalid_answer?)
          expect(validate_answers).to be_valid
        end
      end
    end

    context 'when is invalid' do
      let(:answers) { { 'name_text_1' => '' } }

      it 'returns false' do
        expect(validate_answers).to be_invalid
      end
    end

    context 'validates form metadata' do
      let(:answers) { {} }

      before do
        [
          MetadataPresenter::RequiredValidator,
          MetadataPresenter::MinLengthValidator,
          MetadataPresenter::MaxLengthValidator
        ].each do |klass|
          expect_any_instance_of(klass).to receive(:valid?).and_return(valid)
        end
      end

      context 'when all validations are valid' do
        let(:valid) { true }

        it 'returns true' do
          expect(validate_answers).to be_valid
        end
      end

      context 'when all validations are invalid' do
        let(:valid) { false }

        it 'returns false' do
          expect(validate_answers).to be_invalid
        end
      end
    end
  end
end
