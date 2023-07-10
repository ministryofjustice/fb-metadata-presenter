RSpec.describe MetadataPresenter::AnswersController, type: :controller do
  let(:page) { MetadataPresenter::Page.new(service.find_page_by_url('dog-picture-2')) }
  let(:previous_answers) { {} }
  let(:incoming_answer) { MetadataPresenter::MultiUploadAnswer.new }
  let(:file) do
    ActionDispatch::Http::UploadedFile.new(tempfile: Rails.root.join('spec', 'fixtures', 'thats-not-a-knife.txt'), filename: 'thats-not-a-knife.txt', content_type: "text/plain")
  end
  let(:params) do
    ActionController::Parameters.new({
      'dog-picture_upload_2' => file
    }).permit!
  end
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, incoming_answer, nil) }
  let(:uploaded_file) do
    MetadataPresenter::UploadedFile.new(
    file:,
    component: page.components.first
    )
  end

  context '#upload_multiupload_new_files' do
    before do
      controller.instance_variable_set(:@page, page)
      controller.instance_variable_set(:@previous_answers, previous_answers)
      incoming_answer.key = 'dog-picture_upload_2'
      incoming_answer.incoming_answer = params
      controller.instance_variable_set(:@page_answers, page_answers)
      allow(file).to receive(:tempfile).and_return(OpenStruct.new(path: 'spec/dummy/spec/fixtures/thats-not-a-knife.txt'))
      allow(controller).to receive(:incoming_answer).and_return(incoming_answer)
    end

    it 'uploads the first file' do
      expect_any_instance_of(MetadataPresenter::FileUploader).to receive(:upload).and_return(uploaded_file)
      controller.upload_multiupload_new_files
    end

    it 'uploads additional files' do
      previous_answers = {
        'dog-picture_upload_2' => [{ 'original_filename' => 'a-file.txt'}]
      }

      expect_any_instance_of(MetadataPresenter::FileUploader).to receive(:upload).and_return(uploaded_file)
      controller.upload_multiupload_new_files
    end

    it 'sets an error if the filename is a duplicate' do
      previous_answers = {
        'dog-picture_upload_2' => [{ 'original_filename' => 'thats-not-a-knife.txt'}]
      }
      incoming_answer.incoming_answer = {
        'dog-picture_upload_2' => OpenStruct.new(original_filename: 'thats-not-a-knife.txt')
      }

      allow(controller).to receive(:load_user_data).and_return(previous_answers)
      expect_any_instance_of(MetadataPresenter::FileUploader).to_not receive(:upload)
      controller.upload_multiupload_new_files

      expect(page_answers.uploaded_files.first.errors.first.attribute.to_s).to eq('invalid.multiupload')
    end
  end
end