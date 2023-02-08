RSpec.describe MetadataPresenter::MaxSizeValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }
  let(:page) { service.find_page_by_url('dog-picture') }

  before do
    allow(page_answers).to receive(:uploaded_files).and_return(
      [uploaded_file]
    )
  end

  describe '#valid?' do
    let(:answers) { {} }

    context 'when valid' do
      let(:uploaded_file) do
        double(
          file: {}, error?: false, error_name: nil, component:
        )
      end

      it 'returns true' do
        expect(validator).to be_valid
      end
    end

    context 'when invalid' do
      let(:uploaded_file) do
        double(error?: true, error_name: 'invalid.too-large', component:)
      end

      it 'returns false' do
        expect(validator).to_not be_valid
      end

      it 'returns a custom error message' do
        validator.valid?
        expect(page_answers.errors.full_messages).to eq(
          ['The selected file must be smaller than 7MB.']
        )
      end
    end

    context 'when another error but not file too large' do
      let(:uploaded_file) do
        double(error?: true, error_name: 'invalid.virus', component:)
      end

      it 'returns true' do
        expect(validator).to be_valid
      end
    end
  end

  describe 'human_max_size' do
    let(:answers) { {} }
    let(:uploaded_file) do
      double(
        file: {}, error?: false, error_name: nil, component:
      )
    end

    context 'when max_size is a string' do
      before do
        allow(component.validation).to receive(:[])
        allow(component.validation).to receive(:[]).with('max_size').and_return('7340032')
      end

      it 'returns the correct value' do
        expect(validator.human_max_size).to eq 7
      end
    end
  end
end
