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

    context 'when is invalid' do
      let(:answers) { { 'full_name' => '' } }

      it 'returns false' do
        expect(validate_answers).to be_invalid
      end
    end

    context 'validates from metadata' do
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
