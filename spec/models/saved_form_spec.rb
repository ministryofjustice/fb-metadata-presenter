RSpec.describe MetadataPresenter::SavedForm, type: :model do
  describe 'populating necessary attributes' do
    let(:params) { { 'email' => 'email@email.com', 'saved_form' => { 'page_slug' => 'slug', 'secret_question' => 'some text' }, 'secret_answer' => 'answer' } }
    let(:session) { { user_id: 'idval', user_token: 'token', user_data: { 'field1' => 'answer' } } }
    let(:service) { OpenStruct.new(service_slug: 'service_slug', version_id: '123') }

    it 'should populate from params' do
      subject.populate_param_values(params)

      expect(subject.email).to eq(params['email'])
      expect(subject.page_slug).to eq(params['saved_form']['page_slug'])
      expect(subject.secret_question).to eq(params['saved_form']['secret_question'])
      expect(subject.secret_answer).to eq(params['secret_answer'])

      expect(subject.valid?).to eq(false)
    end

    it 'should populate from session' do
      subject.populate_param_values(params)
      subject.populate_session_values(session)

      expect(subject.user_id).to eq(session[:user_id])
      expect(subject.user_token).to eq(session[:user_token])

      expect(subject.valid?).to eq(false)
    end

    it 'should populate from service' do
      subject.populate_param_values(params)
      subject.populate_service_values(service)

      expect(subject.service_slug).to eq(service.service_slug)
      expect(subject.service_version).to eq(service.version_id)

      expect(subject.valid?).to eq(false)
    end

    it 'should return valid if all attributes are valid' do
      subject.populate_param_values(params)
      subject.populate_session_values(session)
      subject.populate_service_values(service)

      expect(subject.valid?).to eq(true)
    end
  end
end
