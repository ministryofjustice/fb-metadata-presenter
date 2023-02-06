RSpec.describe MetadataPresenter::ServiceController, type: :request do
  describe 'GET /' do
    before do
      get '/'
    end

    it 'returns an ok status' do
      expect(response).to be_successful
    end

    it 'renders the view correctly' do
      start_page_heading = service_metadata['pages'][0]['heading']
      expect(response.body).to include(start_page_heading)
    end

    it 'has no back link' do
      expect(response.body).not_to include('Back')
    end
  end

  context 'maintenance mode enabled' do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('MAINTENANCE_MODE').and_return('1')

      get '/'
    end

    it 'returns an ok status' do
      expect(response).to be_successful
    end

    it 'renders the view correctly' do
      expect(response.body).to include 'Sorry, this form is unavailable'
    end

    it 'renders the maintenance page for any page' do
      get '/name'
      expect(response.body).to include 'Sorry, this form is unavailable'
    end
  end

  describe 'GET /name' do
    before do
      get '/name'
    end

    it 'returns an ok status' do
      expect(response).to be_successful
    end

    it 'renders the view correctly' do
      page_heading = service_metadata['pages'][1]['components'][0]['label']
      expect(response.body).to include(page_heading)
    end
  end

  describe 'GET /non-existent-url' do
    before do
      get '/non-existent-url'
    end

    it 'returns not found' do
      expect(response.status).to be(404)
    end

    it 'renders the view correctly' do
      expect(response.body).to include(
        "The page you were looking for doesn't exist."
      )
    end
  end

  describe 'POST to page URL' do
    context 'when start page' do
      before do
        post '/'
      end

      it 'redirects to the first page' do
        expect(response).to redirect_to('/name')
      end
    end

    context 'when valid' do
      before do
        post '/name',
             params: { answers: { name_text_1: 'Mithrandir' } }
      end

      it 'redirects to next page' do
        expect(response).to redirect_to('/email-address')
      end

      it 'does not upload any file' do
        expect_any_instance_of(
          MetadataPresenter::AnswersController
        ).to_not receive(:upload_files)
        post '/name', params: { answers: { name_text_1: 'Gandalf' } }
      end
    end

    context 'when upload' do
      let(:answers) do
        {
          'dog-picture_upload_1' => {
            'original_filename' => 'we_are_awesome.png'
          }
        }
      end
      before do
        allow_any_instance_of(
          MetadataPresenter::AnswersController
        ).to receive(:upload_adapter)
          .and_return(MetadataPresenter::OfflineUploadAdapter)
      end

      it 'redirect to the next page' do
        post '/dog-picture', params: { answers: }
        expect(response).to redirect_to('/countries')
      end

      it 'uploads the file' do
        expect_any_instance_of(
          MetadataPresenter::AnswersController
        ).to receive(:upload_files)
        post '/dog-picture', params: { answers: }
      end
    end

    context 'when invalid' do
      before do
        post '/name',
             params: { answers: {} }
      end

      it 'returns unprocessable entity' do
        expect(response.status).to be(422)
      end

      it 'render same page' do
        page_heading = service_metadata['pages'][1]['components'][0]['label']
        expect(response.body).to include(page_heading)
      end
    end

    context 'when next page does not exist' do
      let(:service_metadata) do
        JSON.parse(
          File.read(fixtures_directory.join('non_finished_service.json'))
        )
      end

      before do
        expect(Rails.configuration).to receive(:service_metadata).and_return(service_metadata)
        post '/parent-name',
             params: { answers: { parent_name: 'Test' } }
      end

      it 'returns not found' do
        expect(response.status).to be(404)
      end
    end

    context 'when URL does not exist' do
      before do
        post '/non-existent-url'
      end

      it 'should return a 404' do
        expect(response.status).to be(404)
      end
    end
  end

  describe 'POST /confirmation' do
    context 'when there is a confirmation in the metadata' do
      before do
        post '/reserved/submissions'
      end

      it 'redirect to the confirmation' do
        expect(response).to redirect_to('/confirmation')
      end
    end

    context 'when there is no confirmation in the metadata' do
      let(:service_metadata) do
        JSON.parse(
          File.read(fixtures_directory.join('non_finished_service.json'))
        )
      end

      before do
        expect(Rails.configuration).to receive(:service_metadata).and_return(service_metadata)
        post '/reserved/submissions'
      end

      it 'returns not found' do
        expect(response.body).to include(
          "The page you were looking for doesn't exist."
        )
      end
    end
  end

  describe 'GET /reserved/change-answer' do
    before do
      get '/reserved/change-answer', params: { url: '/name' }
    end

    it 'sets the session to return to check your answer page' do
      expect(session[:return_to_check_your_answer]).to be_truthy
    end

    it 'redirect to the url' do
      expect(response).to redirect_to('/name')
    end
  end
end
