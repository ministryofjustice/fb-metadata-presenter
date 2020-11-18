require 'spec_helper'

RSpec.describe MetadataPresenter::ServiceController, type: :routing do
  routes { MetadataPresenter::Engine.routes }
    
  context 'when service metadata exists' do
    let(:service_metadata) do
      File.read(Rails.root.join('spec', 'fixtures', 'service.json'))
    end

    let(:params) do
      { service_metadata: service_metadata.to_json }
    end
    
    before do
      post "start", params: params, as: :json
    end

    it 'returns created status' do
      expect(response.status).to be(200)
    end
  end
end
