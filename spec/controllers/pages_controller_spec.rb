RSpec.describe MetadataPresenter::PagesController do
  describe '#page_presenters' do
    let(:user_data) { { 'han' => 'Let the Wookiee win' } }
    before do
      controller.instance_variable_set(:@user_data, user_data)
    end

    it 'maps the answers' do
      expect(MetadataPresenter::PageAnswersPresenter).to receive(:map)
      controller.pages_presenters
    end
  end
end
