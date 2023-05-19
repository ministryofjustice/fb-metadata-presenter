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

  describe 'count duplicate filenames' do
    let(:user_data) do
      {
        'dog_picture_upload-1' => 'peanut.jpg',
        'dog_picture_upload-2' => 'peanut.jpg',
        'dog_picture_upload-3' => 'notpeanut.jpg'
      }

      it 'counts matches' do
        expect(controller.update_count_matching_filenames(user_data, 'peanut.jpg')).to eq(2)
        expect(controller.update_count_matching_filenames(user_data, 'peanut2.jpg')).to eq(0)
        expect(controller.update_count_matching_filenames(user_data, 'peanut-(1).jpg')).to eq(0)
      end
    end
  end
end
