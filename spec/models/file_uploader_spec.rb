RSpec.describe MetadataPresenter::FileUploader do
  subject(:file_uploader) do
    described_class.new(
      session:,
      page_answers:,
      component:,
      adapter:
    )
  end
  let(:adapter) { double }
  let(:session) { { session_id: '3337407fcd59870be6f15daccf17d311' } }
  let(:component) do
    double(id: 'dog-picture', validation: { 'accept' => accept })
  end
  let(:accept) { %w[text/csv] }

  describe '#upload' do
    context 'when there is no file' do
      let(:page_answers) do
        double(
          'dog-picture' => nil
        )
      end

      it 'returns an empty uploaded file' do
        expect(adapter).to_not receive(:new)
        expect(file_uploader.upload).to eq(
          MetadataPresenter::UploadedFile.new(
            file: {},
            component:
          )
        )
      end
    end

    context 'when there is a file' do
      let(:page_answers) do
        double(
          'dog-picture' => file_details
        )
      end
      let(:file_details) do
        {
          'original_filename' => './spec/fixtures/thats-not-a-knife.txt',
          'content_type' => 'text/plain',
          'tempfile' => Rails.root.join('spec', 'fixtures', 'thats-not-a-knife.txt')
        }
      end

      it 'returns uploaded file' do
        expect(adapter).to receive(:new).with(
          session:,
          file_details:,
          allowed_file_types: accept
        ).and_return(double(call: { 'fingerprint' => '28d' }))
        expect(file_uploader.upload).to eq(
          MetadataPresenter::UploadedFile.new(
            file: { 'fingerprint' => '28d' },
            component:
          )
        )
      end
    end
  end
end
