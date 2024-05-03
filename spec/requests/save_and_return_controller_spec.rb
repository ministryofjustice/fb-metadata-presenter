RSpec.describe MetadataPresenter::SaveAndReturnController, type: :request do
  describe '#show' do
    it 'shows the page' do
      get '/save'
      expect(response.status).to eq(200)
    end
  end

  describe '#create' do
    context 'valid request' do
      it 'posts the save progress form' do
        session = { user_id: '1324', user_token: 'token', user_data_payload: { 'question_1' => 'answer' } }
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:session).and_return(session)

        params = { email: 'valid@example.com', secret_answer: 'secret stuff', saved_form: { page_slug: '/a-page', secret_question: 1 } }

        service = OpenStruct.new(version_id: '4567')
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:service).and_return(service)

        post('/saved_forms', params:)

        expect(response).to redirect_to('/save/email_confirmation')

        expect(session[:saved_form].email).to eq(params[:email])
        expect(session[:saved_form].page_slug).to eq(params[:saved_form][:page_slug])
        expect(session[:saved_form].secret_answer).to eq(params[:secret_answer])
        expect(session[:saved_form].secret_question).to eq(controller.text_for(params[:saved_form][:secret_question]))
        expect(session[:saved_form].service_slug).to eq(params[:service_slug])
        expect(session[:saved_form].service_version).to eq(service.version_id)
        expect(session[:saved_form].user_id).to eq(session[:user_id])
        expect(session[:saved_form].user_token).to eq(session[:user_token])
      end
    end

    context 'invalid request' do
      it 're-renders with errors' do
        params = { email: 'not valid', secret_answer: 'secret stuff', saved_form: { page_slug: '/a-page', secret_question: 1 } }

        post('/saved_forms', params:)

        expect(response.request.path).to eq('/saved_forms')
        expect(session[:saved_form]).to eq(nil)
      end
    end
  end

  describe '#show email confirmation' do
    it 'should populate from session' do
      session = OpenStruct.new(saved_form: { 'email' => 'email@email.com' })
      allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:session).and_return(session)

      get '/save/email_confirmation'
      expect(response.status).to eq(200)
    end
  end

  describe '#confirm_email' do
    context 'Successful POST to datastore' do
      let(:email) { 'email@123.com' }
      let(:id) { '12345' }
      let(:status) { 200 }

      before do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:save_form_progress)
          .and_return(OpenStruct.new(status:, body: { id: }))
        session = { 'saved_form' => { 'email' => email } }
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:session).and_return(session)
      end

      it 'should redirect with status' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:create_save_and_return_submission).with({ email:, id: })

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

    context 'failed to validate email' do
      let(:email) { 'email@123.com' }

      it 'should redirect with status' do
        post '/email_confirmations', params: { email_confirmation: '' }

        expect(response.status).to eq(422)
        expect(response.request.path).to eq('/email_confirmations')
      end

      it 'should redirect with status' do
        post '/email_confirmations', params: { email_confirmation: 'not the right format' }

        expect(response.status).to eq(422)
        expect(response.request.path).to eq('/email_confirmations')
      end
    end
  end

  describe 'progress saved' do
    before do
      expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:destroy_session).and_return(true)
    end

    it 'clears the session, but preserves the page slug to prevent errors' do
      session = { 'user_id' => '1324', 'user_token' => 'token', 'saved_form' => { 'email' => 'email', 'page_slug' => 'a-cool-page' } }
      allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:session).and_return(session)

      get '/save/progress_saved'

      expect(response.status).to eq(200)
    end
  end

  describe 'helper methods' do
    let(:controller) { MetadataPresenter::SaveAndReturnController.new }

    context 'secret questions' do
      it 'returns three questions' do
        expect(controller.secret_questions.count).to eq(3)
      end
    end

    context 'text for' do
      %w[
        one
        two
        three
      ].each_with_index do |option, index|
        it "returns the text for the html value #{index + 1}" do
          expect(controller.text_for(index + 1)).to eq(I18n.t("presenter.save_and_return.secret_questions.#{option}"))
        end
      end
    end

    context 'page slug' do
      let(:correct_slug) { '/a-cool-page' }

      it 'returns session slug if set during return flow' do
        allow(controller).to receive(:session).and_return({ 'returning_slug' => correct_slug })
        allow(controller).to receive(:params).and_return({})

        expect(controller.page_slug).to eq(correct_slug)
      end

      it 'returns session slug if set during save flow' do
        allow(controller).to receive(:session).and_return({ 'returning_slug' => nil, 'saved_form' => { 'page_slug' => correct_slug } })
        allow(controller).to receive(:params).and_return({})

        expect(controller.page_slug).to eq(correct_slug)
      end

      it 'returns params slug if no session is set' do
        allow(controller).to receive(:session).and_return({ 'returning_slug' => nil, 'saved_form' => nil })
        allow(controller).to receive(:params).and_return({ page_slug: correct_slug })

        expect(controller.page_slug).to eq(correct_slug)
      end
    end

    context 'confirmed email' do
      let(:email) { 'email@example.com' }

      it 'returns the email from the session' do
        allow(controller).to receive(:session).and_return({ 'saved_form' => { 'email' => email } })

        expect(controller.confirmed_email).to eq(email)
      end
    end

    context 'label text' do
      let(:text) { 'hello' }

      it 'adds a h2 to the text' do
        expect(controller.label_text(text)).to eq("<h2 class='govuk-heading-m'>hello</h2>")
      end
    end
  end
end
