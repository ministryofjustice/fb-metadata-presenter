RSpec.describe MetadataPresenter::FileUploader do
  subject(:file_uploader) do
    described_class.new(
      session: session,
      page_answers: page_answers,
      component: component,
      adapter: adapter
    )
  end
  let(:adapter) { double }
  let(:session) { { session_id: '3337407fcd59870be6f15daccf17d311' } }
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
  let(:component) do
    double(id: 'dog-picture', validation: { 'accept' => accept })
  end
  let(:accept) { %w[text/csv] }

  describe '#upload' do
    it 'returns uploaded file' do
      expect(adapter).to receive(:new).with(
        session: session,
        file_details: file_details,
        allowed_file_types: accept
      ).and_return(double(call: { 'fingerprint' => '28d' }))
      expect(file_uploader.upload).to eq(
        MetadataPresenter::UploadedFile.new(
          file: { 'fingerprint' => '28d' },
          component: component
        )
      )
    end
  end
end
