RSpec.describe MetadataPresenter::VirusScanValidator do
  subject(:validator) do
    described_class.new(page_answers: page_answers, component: component)
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
    let(:answers) do
      {
        component.id => {
          'original_filename' => 'scooby_do.txt'
        }
      }
    end

    context 'when valid' do
      let(:uploaded_file) do
        double(
          file: {}, error?: false, error_name: nil, component: component
        )
      end

      it 'returns true' do
        expect(validator).to be_valid
      end
    end

    context 'when invalid' do
      let(:uploaded_file) do
        double(error?: true, error_name: 'invalid.virus', component: component)
      end

      it 'returns false' do
        expect(validator).to_not be_valid
      end

      it 'returns a custom error message' do
        validator.valid?
        expect(page_answers.errors.full_messages).to eq(
          ['"scooby_do.txt" was not uploaded successfully because it contains a virus']
        )
      end
    end

    context 'when another error but not file too large' do
      let(:uploaded_file) do
        double(error?: true, error_name: 'invalid.too-large', component: component)
      end

      it 'returns true' do
        expect(validator).to be_valid
      end
    end
  end
end
