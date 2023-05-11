RSpec.describe 'Save and Return Controller Requests', type: :request do
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

        service = OpenStruct.new(service_slug: 'service_slug', version_id: '4567')
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:service).and_return(service)

        post('/saved_forms', params:)

        expect(response).to redirect_to('/save/email_confirmation')

        expect(session[:saved_form].email).to eq(params[:email])
        expect(session[:saved_form].page_slug).to eq(params[:saved_form][:page_slug])
        expect(session[:saved_form].secret_answer).to eq(params[:secret_answer])
        expect(session[:saved_form].secret_question).to eq(controller.text_for(params[:saved_form][:secret_question]))
        expect(session[:saved_form].service_slug).to eq(service.service_slug)
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
    it 'clears the session, but preserves the page slug to prevent errors' do
      session = { 'user_id' => '1324', 'user_token' => 'token', 'saved_form' => { 'email' => 'email', 'page_slug' => 'a-cool-page' } }
      allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:session).and_return(session)

      get '/save/progress_saved'

      expect(controller.session['user_id']).to eq(nil)
      expect(controller.session['user_token']).to eq(nil)
      expect(controller.session['saved_form']['user_id']).to eq(nil)
      expect(controller.session['saved_form']['user_token']).to eq(nil)
      expect(controller.session['saved_form']['page_slug']).to eq(session['saved_form']['page_slug'])
    end
  end

  describe '#resume progress' do
    context 'return to service' do
      let(:uuid) { '1234-1234' }
      let(:saved_form_body) { JSON.parse("{\"id\":\"2369f3f3-8bdd-4581-a367-90e34f3aef17\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"some more text\",\"page_slug\":\"email-address\",\"service_slug\":\"some-slug\",\"service_version\":\"27dc30c9-f7b8-4dec-973a-bd153f6797df\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"0.0\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}") }

      it 'should redirect to record error if the record is not found' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid)
        .and_return(OpenStruct.new(status: 404))

        get "/return/#{uuid}"

        expect(response).to redirect_to('/record_error')
      end

      it 'should redirect to already used if the record has beed used/invalidated' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid)
        .and_return(OpenStruct.new(status: 422))

        get "/return/#{uuid}"

        expect(response).to redirect_to('/already_used')
      end

      it 'should redirect to too many attempts if the record has beed used/invalidated' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid)
        .and_return(OpenStruct.new(status: 400))

        get "/return/#{uuid}"

        expect(response).to redirect_to('/record_failure')
      end

      it 'should populate objects on successful return' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid)
        .and_return(OpenStruct.new(status: 200, body: saved_form_body))

        get "/return/#{uuid}"

        expect(response.status).to eq(200)
      end
    end
  end

  describe '#submit secret answer' do
    let(:uuid) { '2369f3f3-8bdd-4581-a367-90e34f3aef17' }
    let(:secret_answer) { 'text answer' }
    let(:version_id) { '27dc30c9-f7b8-4dec-973a-bd153f6797df' }
    let(:saved_form) { OpenStruct.new(status: 200, body: JSON.parse("{\"id\":\"#{uuid}\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"#{secret_answer}\",\"page_slug\":\"email-address\",\"service_slug\":\"some-slug\",\"service_version\":\"#{version_id}\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"0.0\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}")) }

    context 'answer is valid' do
      it 'redirects to resume progress if versions match' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid).and_return(saved_form)
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:service).and_return(OpenStruct.new(version_id:))
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:invalidate_record).with(uuid)

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response).to redirect_to('/resume_progress')
      end

      it 'redirects to resume from start if versions do not match' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid).and_return(saved_form)
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:service).and_return(OpenStruct.new(version_id: 'something else'))
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:invalidate_record).with(uuid)

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response).to redirect_to('/resume_from_start')
      end
    end

    context 'answer is not valid' do
      let(:secret_answer) { 'some other answer' }
      let(:saved_form) { OpenStruct.new(status: 200, body: JSON.parse("{\"id\":\"#{uuid}\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"not a match\",\"page_slug\":\"email-address\",\"service_slug\":\"some-slug\",\"service_version\":\"#{version_id}\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"0.0\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}")) }
      let(:attempted_saved_form) { OpenStruct.new(status: 200, body: JSON.parse("{\"id\":\"#{uuid}\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"not a match\",\"page_slug\":\"email-address\",\"service_slug\":\"some-slug\",\"service_version\":\"#{version_id}\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"3\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}")) }

      it 're-renders with validation error' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid).and_return(saved_form)
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:increment_record_counter).with(uuid)
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:service).and_return(OpenStruct.new(service_name: 'service'))

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response.request.path).to eq('/resume_forms')
      end

      it 're-renders with validation error then redirects after last attempt' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid).and_return(OpenStruct.new(status: 400))

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response.request.path).to redirect_to('/record_failure')
      end

      it 'redirects if too many attempts' do
        expect_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:get_saved_progress).with(uuid).and_return(attempted_saved_form)
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:service).and_return(OpenStruct.new(service_name: 'service'))

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response).to redirect_to('/record_failure')
      end
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
      let(:correct_slug) { 'a-cool-page' }

      it 'returns session slug if set during return flow' do
        allow(controller).to receive(:session).and_return({ 'returning_slug' => correct_slug })

        expect(controller.page_slug).to eq(correct_slug)
      end

      it 'returns session slug if set during save flow' do
        allow(controller).to receive(:session).and_return({ 'returning_slug' => nil, 'saved_form' => { 'page_slug' => correct_slug } })

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

    context 'service name' do
      let(:service_name) { 'a-cool-service' }

      it 'returns the service name' do
        allow_any_instance_of(MetadataPresenter::SaveAndReturnController).to receive(:service).and_return(OpenStruct.new(service_name:))

        expect(controller.get_service_name).to eq(service_name)
      end
    end
  end
end
