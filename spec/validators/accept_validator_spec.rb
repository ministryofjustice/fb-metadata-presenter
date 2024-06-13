RSpec.describe MetadataPresenter::AcceptValidator do
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
    let(:answers) do
      {
        component.id => {
          'original_filename' => 'beethoven.txt'
        }
      }
    end

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
        double(error?: true, error_name: 'accept', component:)
      end

      it 'returns false' do
        expect(validator).to_not be_valid
      end

      it 'returns a custom error message' do
        validator.valid?
        expect(page_answers.errors.full_messages).to eq(
          ['"beethoven.txt" cannot be uploaded. Files must be one of the following file types: portable document format (.pdf), comma-separated values (.csv), images (.jpg, .jpeg, .png), Microsoft Excel (.xls, xlsx), Microsoft Word (.doc, .docx), Open Office (.odt, .ods), plain text (.txt), rich text (.rtf).']
        )
      end
    end

    context 'when another error but not file format' do
      let(:uploaded_file) do
        double(error?: true, error_name: 'invalid.virus', component:)
      end

      it 'returns true' do
        expect(validator).to be_valid
      end
    end
  end
end
