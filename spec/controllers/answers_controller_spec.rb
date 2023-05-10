RSpec.describe 'Answers Controller Requests', type: :request do
  describe '#create' do
    it 'saves and redirects if the param is set' do
      expect_any_instance_of(MetadataPresenter::AnswersController).to receive(:save_user_data)
      post '/', params: { save_for_later: true }
      
      expect(response).to redirect_to('/save')
    end

    it 'does not save from check your answers' do
      expect_any_instance_of(MetadataPresenter::AnswersController).to_not receive(:save_user_data)
      post '/', params: { save_for_later_check_answers: true }
      
      expect(response).to redirect_to('/save')
    end
  end
end