RSpec.describe MetadataPresenter::ResumeController, type: :request do
  describe '#resume progress' do
    context 'return to service' do
      let(:uuid) { '1234-1234' }
      let(:saved_form_body) { JSON.parse("{\"id\":\"2369f3f3-8bdd-4581-a367-90e34f3aef17\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"some more text\",\"page_slug\":\"email-address\",\"service_slug\":\"some-slug\",\"service_version\":\"27dc30c9-f7b8-4dec-973a-bd153f6797df\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"0.0\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}") }

      it 'should redirect to record error if the record is not found' do
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid)
        .and_return(OpenStruct.new(status: 404))

        get "/return/#{uuid}"

        expect(response).to redirect_to('/record_error')
      end

      it 'should redirect to already used if the record has beed used/invalidated' do
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid)
        .and_return(OpenStruct.new(status: 422))

        get "/return/#{uuid}"

        expect(response).to redirect_to('/already_used')
      end

      it 'should redirect to too many attempts if the record has beed used/invalidated' do
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid)
        .and_return(OpenStruct.new(status: 400))

        get "/return/#{uuid}"

        expect(response).to redirect_to('/record_failure')
      end

      it 'should populate objects on successful return' do
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid)
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
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid).and_return(saved_form)
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:service).at_least(1).and_return(OpenStruct.new(version_id:))
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:invalidate_record).with(uuid)

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response).to redirect_to('/resume_progress')
        expect(response.cookies['_fb_authorised']).to be_nil
      end

      it 'redirects to resume from start if versions do not match' do
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid).and_return(saved_form)
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:service).at_least(1).and_return(OpenStruct.new(version_id: 'something else'))
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:invalidate_record).with(uuid)

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response).to redirect_to('/resume_from_start')
        expect(response.cookies['_fb_authorised']).to be_nil
      end

      context 'when basic auth is enabled' do
        before do
          allow(ENV).to receive(:[])
          allow(ENV).to receive(:[]).with('BASIC_AUTH_USER').and_return('username')
          allow(ENV).to receive(:[]).with('BASIC_AUTH_PASS').and_return('password')
        end

        it 'authorises the session' do
          expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid).and_return(saved_form)
          expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:service).at_least(1).and_return(OpenStruct.new(version_id:))
          expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:invalidate_record).with(uuid)

          post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

          expect(response).to redirect_to('/resume_progress')
          expect(response.cookies['_fb_authorised']).not_to be_nil
        end
      end
    end

    context 'answer is not valid' do
      let(:secret_answer) { 'some other answer' }
      let(:saved_form) { OpenStruct.new(status: 200, body: JSON.parse("{\"id\":\"#{uuid}\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"not a match\",\"page_slug\":\"email-address\",\"service_slug\":\"some-slug\",\"service_version\":\"#{version_id}\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"0.0\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}")) }
      let(:attempted_saved_form) { OpenStruct.new(status: 200, body: JSON.parse("{\"id\":\"#{uuid}\",\"email\":\"email@email.com\",\"secret_question\":\"What was your mother's maiden name?\",\"secret_answer\":\"not a match\",\"page_slug\":\"email-address\",\"service_slug\":\"some-slug\",\"service_version\":\"#{version_id}\",\"user_id\":\"8acfb3db90002a5fc5b43e71638fc709\",\"user_token\":\"b9cca34d4331399c5f461c0ba1c406aa\",\"user_data_payload\":\"{\\\"name_text_1\\\"=\\u003e\\\"Name\\\"}\",\"attempts\":\"3\",\"active\":true,\"created_at\":\"2023-04-12T10:28:48.370Z\",\"updated_at\":\"2023-04-12T10:28:48.370Z\"}")) }

      after do
        expect(response.cookies['_fb_authorised']).to be_nil
      end

      it 're-renders with validation error' do
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid).and_return(saved_form)
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:increment_record_counter).with(uuid)
        allow_any_instance_of(MetadataPresenter::ResumeController).to receive(:service).and_return(OpenStruct.new(service_name: 'service'))

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response.request.path).to eq('/resume_forms')
      end

      it 're-renders with validation error then redirects after last attempt' do
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid).and_return(OpenStruct.new(status: 400))

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response.request.path).to redirect_to('/record_failure')
      end

      it 'redirects if too many attempts' do
        expect_any_instance_of(MetadataPresenter::ResumeController).to receive(:get_saved_progress).with(uuid).and_return(attempted_saved_form)
        allow_any_instance_of(MetadataPresenter::ResumeController).to receive(:service).and_return(OpenStruct.new(service_name: 'service'))

        post '/resume_forms', params: { resume_form: { uuid:, secret_answer: } }

        expect(response).to redirect_to('/record_failure')
      end
    end
  end

  describe 'helper methods' do
    let(:controller) { MetadataPresenter::ResumeController.new }

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

    context 'label text' do
      let(:text) { 'hello' }

      it 'adds a h2 to the text' do
        expect(controller.label_text(text)).to eq("<h2 class='govuk-heading-m'>hello</h2>")
      end
    end
  end
end
