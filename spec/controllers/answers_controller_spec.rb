RSpec.describe 'Answers Controller Requests', type: :request do
  describe '#create' do
    it 'saves and redirects if the param is set' do
      expect_any_instance_of(MetadataPresenter::AnswersController).to receive(:save_user_data)
      post '/', params: { save_for_later: true }

      expect(response).to redirect_to('/save')
    end
  end

  describe 'reserved submissions path' do
    it 'does not create a submission from check your answers' do
      expect_any_instance_of(MetadataPresenter::SubmissionsController).to_not receive(:create_submission)
      post '/reserved/submissions', params: { save_for_later_check_answers: true }

      expect(response).to redirect_to('/save')
    end
  end

  describe 'checking for duplicate uploads' do
    let(:user_data) do
      {
        "dog-picture_upload_1"=>{"original_filename" => "peanut.jpg"}
      }
    end

    let(:answer) do
      {
        "dog-picture_upload_2"=>{"original_filename" => "peanut.jpg"}
      }
    end

    it 'adds the right count to the page answers' do

      allow_any_instance_of(MetadataPresenter::AnswersController).to receive(:load_user_data).and_return(user_data)
      expect_any_instance_of(MetadataPresenter::PageAnswers).to receive(:count).with(1)
      post '/'
    end
  end
end
