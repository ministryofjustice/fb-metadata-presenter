RSpec.describe MetadataPresenter::EngineController, type: :controller do
  describe '#back_link' do
    before do
      allow(controller.request).to receive(:script_name).and_return(script_name)
      allow(controller.request).to receive(:referrer).and_return(referrer)
    end

    context 'when in preview' do
      let(:script_name) do
        '/services/1/preview'
      end

      before do
        controller.instance_variable_set(:@page, page)
      end

      context 'when there is a page' do
        let(:page) { MetadataPresenter::Page.new(service.pages.second) }
        let(:referrer) { 'http://localhost:3000/services/1/preview' }

        it 'returns the previous page' do
          expect(controller.back_link).to eq('/services/1/preview/')
        end
      end

      context 'when there is no page' do
        let(:page) { MetadataPresenter::Page.new(service.pages.first) }
        let(:referrer) { nil }

        it 'returns nil' do
          expect(controller.back_link).to be_nil
        end
      end
    end

    context 'when in the runner' do
      let(:script_name) { '' }

      context 'when there is a page' do
        let(:page) { MetadataPresenter::Page.new(service.pages.second) }
        let(:referrer) { '/' }

        before do
          controller.instance_variable_set(:@page, page)
        end

        it 'returns the previous page' do
          expect(controller.back_link).to eq('/')
        end
      end

      context 'when there is no page' do
        let(:referrer) { nil }

        it 'returns nil' do
          expect(controller.back_link).to be_nil
        end
      end
    end
  end
end
