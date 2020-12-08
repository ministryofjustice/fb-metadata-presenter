require 'spec_helper'

RSpec.describe MetadataPresenter::ServiceController, type: :controller do
  routes { MetadataPresenter::Engine.routes }

  let(:service_metadata) do
    File.read(
      MetadataPresenter::Engine.root.join('spec', 'fixtures', 'service.json')
    )
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

    it 'has no back link' do
      expect(response.body).not_to include('govuk-back-link')
    end
  end
end
