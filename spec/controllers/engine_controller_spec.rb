RSpec.describe MetadataPresenter::EngineController, type: :controller do
  describe '#back_link' do
    context 'when there is a page' do
      let(:page) { MetadataPresenter::Page.new(service.pages.second) }

      before do
        controller.instance_variable_set(:@page, page)
      end

      it 'returns the previous page' do
        expect(controller.back_link).to eq('/')
      end
    end

    context 'when there is no page' do
      it 'returns nil' do
        expect(controller.back_link).to be_nil
      end
    end
  end
end
