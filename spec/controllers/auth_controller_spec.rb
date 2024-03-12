RSpec.describe MetadataPresenter::AuthController, type: :controller do
  routes { MetadataPresenter::Engine.routes }

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('BASIC_AUTH_USER').and_return(username)
    allow(ENV).to receive(:[]).with('BASIC_AUTH_PASS').and_return(password)
  end

  let(:username) { 'username' }
  let(:password) { 'password' }

  describe '#show' do
    context 'when there are no basic auth credentials set' do
      let(:username) { nil }
      let(:password) { nil }

      it 'redirects to the homepage' do
        get :show
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when there are basic auth credentials set' do
      context 'when session is already authorised' do
        it 'redirects to the homepage' do
          cookies.signed['_fb_authorised'] = 1

          get :show
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when session is not authorised yet' do
        it 'shows the sign in page' do
          get :show
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe '#create' do
    context 'for invalid credentials' do
      it 'does not authorise the user and renders the sign in page' do
        post :create, params: { auth_form: { username: 'foo', password: 'bar' } }

        expect(response).to have_http_status(:ok)
        expect(response.cookies['_fb_authorised']).to be_nil
      end
    end

    context 'for valid credentials' do
      it 'authorises the user and redirects to the homepage' do
        post :create, params: { auth_form: { username:, password: } }

        expect(response).to redirect_to(root_path)
        expect(response.cookies['_fb_authorised']).not_to be_nil
      end
    end
  end
end
