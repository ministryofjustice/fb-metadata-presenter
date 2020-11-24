require 'spec_helper'

RSpec.describe MetadataPresenter::ServiceController, type: :controller do
  routes { MetadataPresenter::Engine.routes }

  let(:service_metadata) do
    File.read(Rails.root.join('spec', 'fixtures', 'service.json'))
  end

  let(:params) do
    { service_metadata: service_metadata.to_json }
  end

  context '#start' do
    render_views

    before do
      allow(controller).to receive(:service_metadata).and_return(JSON.parse(service_metadata))
      get :start
    end

    it 'returns an ok status' do
      expect(response).to be_successful
    end

    it 'renders the view correctly' do
      start_page_heading = JSON.parse(service_metadata)['pages'][0]['heading']
      expect(response.body).to include(start_page_heading)
    end
  end

  # context '#answers' do
  #   before do
  #     allow(controller).to receive(:service_metadata).and_return(JSON.parse(service_metadata))

  #     foo = double(url: "Foo")
  #     allow_any_instance_of(MetadataPresenter::Service).to receive(:next_page).and_return(foo)
  #   subject { post :answer, params: { answers: { name: "Foo" } } }
  #   end

  #   it 'returns an ok status' do
  #     expect(subject).to redirect_to action: :render_page
  #   end
  # end
end
