RSpec.describe 'Answers Controller Requests', type: :request do
  describe '#create' do
    let(:components) { [OpenStruct.new(_type: 'multiupload', id: 'dog_pictures')] }
    let(:page) { OpenStruct.new(components:, metadata: OpenStruct.new(components:)) }

    it 'saves and redirects if the param is set' do
      expect_any_instance_of(MetadataPresenter::AnswersController).to receive(:save_user_data)
      post '/', params: { save_for_later: true }

      expect(response).to redirect_to('/save')
    end

    it 'redirects when continuing if more files to upload' do
      allow_any_instance_of(MetadataPresenter::AnswersController).to receive(:page).and_return(page)
      allow_any_instance_of(MetadataPresenter::AnswersController).to receive(:multiupload?).and_return(true)
      expect_any_instance_of(MetadataPresenter::AnswersController).to receive(:save_user_data)
      expect_any_instance_of(MetadataPresenter::AnswersController).to receive(:upload_multiupload_new_files)

      post '/', params: { answers: { 'file' => 'a-new-file' } }
      expect(response).to redirect_to('/') # refers back to same page which is
    end

    it 'redirects to next when continuing if no upload file was given' do
      allow_any_instance_of(MetadataPresenter::AnswersController).to receive(:page).and_return(page)
      allow_any_instance_of(MetadataPresenter::AnswersController).to receive(:multiupload?).and_return(true)
      expect_any_instance_of(MetadataPresenter::AnswersController).to receive(:save_user_data)
      expect_any_instance_of(MetadataPresenter::AnswersController).to_not receive(:upload_multiupload_new_files)

      post '/name'
      expect(response).to redirect_to('/email-address') # refers back to next page, see version.json to maintain
    end
  end

  describe 'reserved submissions path' do
    it 'does not create a submission from check your answers' do
      expect_any_instance_of(MetadataPresenter::SubmissionsController).to_not receive(:create_submission)
      post '/reserved/submissions', params: { save_for_later_check_answers: true }

      expect(response).to redirect_to('/save')
    end
  end

  describe 'count duplicate filenames' do
    let(:controller) { MetadataPresenter::AnswersController.new }
    let(:user_data) do
      {
        'dog_picture_upload-1' => { 'original_filename' => 'peanut.jpg' },
        'dog_picture_upload-2' => { 'original_filename' => 'peanut.jpg' },
        'dog_picture_upload-3' => { 'original_filename' => 'notpeanut.jpg' },
        'dog_picture_multi_upload-4' => [{ 'original_filename' => 'notpeanut.jpg' }],
        'another_type_of_question' => 'peanut.jpg'
      }
    end

    it 'counts matches' do
      expect(controller.update_count_matching_filenames('peanut.jpg', user_data)).to eq(2)
      expect(controller.update_count_matching_filenames('peanut2.jpg', user_data)).to eq(0)
      expect(controller.update_count_matching_filenames('peanut-(1).jpg', user_data)).to eq(0)
    end
  end
end
