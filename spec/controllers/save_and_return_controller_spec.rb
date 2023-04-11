RSpec.describe 'Save and Return Controller Requests', type: :request do
  # describe '#create' do
  #   it 'posts the save progress form' do
  #     post :create, params: { stuff: 'foo ' }, body: {}

  #     expect(response).to redirect_to('/save/email_confirmation')
  #     expect(session[:saved_form]).to eq({})
  #   end
  # end

  describe '#confirm_email' do
    context 'Successful POST to datastore' do
      let(:email) { 'email@123.com' }

      it 'should redirect with status' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:save_form_progress)
          .and_return(OpenStruct.new(status: 200))
        session = { 'saved_form' => { 'email' => email } }
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:session).and_return(session)

        post '/email_confirmations', params: { email_confirmation: email }

        expect(response).to redirect_to('/save/progress_saved')
      end
    end

    context 'failed POST to datastore' do
      let(:email) { 'email@123.com' }

      it 'should redirect with status' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:save_form_progress)
          .and_return(OpenStruct.new(status: 500))
        session = { 'saved_form' => { 'email' => email } }
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:session).and_return(session)

        post '/email_confirmations', params: { email_confirmation: email }

        expect(response.status).to eq(500)
      end
    end

    context 'failed to match email to session' do
      let(:email) { 'email@123.com' }

      it 'should redirect with status' do
        session = { 'saved_form' => { 'email' => 'not-a-match@email.com' } }
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:session).and_return(session)

        post '/email_confirmations', params: { email_confirmation: email }

        expect(response.status).to eq(422)
        expect(response.request.path).to eq('/email_confirmations')
      end
    end
  end
end
