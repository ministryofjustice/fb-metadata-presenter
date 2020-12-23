RSpec.describe MetadataPresenter::ValidateAnswers do
  subject(:validate_answers) do
    described_class.new(page: page, answers: answers)
  end

  describe '#valid?' do
    let(:page) { service.find_page('/name') }

    context 'when is valid' do
      let(:answers) { { 'full_name' => 'Gandalf' } }

      it 'returns true' do
        expect(validate_answers).to be_valid
      end
    end

    context 'when validation required = false in metadata' do
      let(:page) { service.find_page('/parent-name') }

      context 'when no answer is provided' do
        let(:answers) { { 'parent_name' => '' } }

        it 'does not attempt any validations' do
          expect_any_instance_of(MetadataPresenter::RequiredValidator).not_to receive(:invalid_answer?)
          expect_any_instance_of(MetadataPresenter::MinLengthValidator).not_to receive(:invalid_answer?)
          expect_any_instance_of(MetadataPresenter::MaxLengthValidator).not_to receive(:invalid_answer?)
          expect(validate_answers).to be_valid
        end
      end

      context 'when an answer is provided' do
        let(:answers) { { 'parent_name' => 'Grogu' } }

        it 'should validate the answer' do
          expect_any_instance_of(MetadataPresenter::RequiredValidator).not_to receive(:invalid_answer?)
          expect_any_instance_of(MetadataPresenter::MinLengthValidator).to receive(:invalid_answer?)
          expect_any_instance_of(MetadataPresenter::MaxLengthValidator).to receive(:invalid_answer?)
          expect(validate_answers).to be_valid
        end
      end
    end

    context 'when is invalid' do
      let(:answers) { { 'full_name' => '' } }

      it 'returns false' do
        expect(validate_answers).to be_invalid
      end
    end

    context 'validates form metadata' do
      let(:answers) { {} }

      before do
        [MetadataPresenter::RequiredValidator, MetadataPresenter::MinLengthValidator, MetadataPresenter::MaxLengthValidator].each do |klass|
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
