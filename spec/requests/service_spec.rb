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

  describe 'GET /name' do
    before do
      get '/name'
    end

    it 'returns an ok status' do
      expect(response).to be_successful
    end

    it 'renders the view correctly' do
      page_heading = service_metadata['pages'][1]['heading']
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

  describe 'POST /reserved/%2Fname/answers' do
    context 'when valid' do
      before do
        post '/reserved/%2Fname/answers',
          params: { answers: { full_name: 'Mithrandir' } }
      end

      it 'redirects to next page' do
        expect(response).to redirect_to('/email-address')
      end
    end

    context 'when invalid' do
      before do
        post '/reserved/%2Fname/answers',
          params: { answers: { } }
      end

      it 'returns unprocessable entity' do
        expect(response.status).to be(422)
      end

      it 'render same page' do
        page_heading = service_metadata['pages'][1]['heading']
        expect(response.body).to include(page_heading)
      end
    end

    context 'when next page does not exist' do
      before do
        post '/reserved/%2Fparent-name/answers',
          params: { answers: { parent_name: 'Test' } }
      end

      it 'returns not found' do
        expect(response.status).to be(404)
      end
    end
  end
end
