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

  describe '#show' do
    context 'when page exists' do
      let(:page) { double(MetadataPresenter::Page) }
      let(:template_page) { 'metadata_presenter/page/start' }
      let(:a_response) { { status: 'OK' } }

      before do
        allow(page).to receive(:template).and_return(template_page)
        allow(page).to receive(:autocomplete_component_present?).and_return(false)
        allow(page).to receive(:load_all_content)
        allow(page).to receive(:load_conditional_content)
        controller.instance_variable_set(:@page, page)
        allow_any_instance_of(ActionController::Instrumentation).to receive(:render).and_return(a_response)
      end

      it 'renders a template with conditional content' do
        expect(controller).to receive(:render)
        controller.show
      end
    end

    context 'when page does not exist' do
      before do
        allow_any_instance_of(MetadataPresenter::Service).to receive(:find_page_by_url).and_return(nil)
      end

      it 'renders the not found template' do
        expect(controller).to receive(:not_found)
        controller.show
      end
    end
  end

  describe '#show_save_and_return' do
    let(:page) { double(MetadataPresenter::Page) }

    before do
      allow(page).to receive(:upload_components).and_return(upload_components)
      controller.instance_variable_set(:@page, page)
    end

    context 'when there are no upload components' do
      let(:upload_components) { {} }

      it 'shows save and return' do
        expect(controller.show_save_and_return).to be_truthy
      end
    end

    context 'when there are upload components' do
      let(:upload_components) { %w[A B] }

      it 'does not show save and return' do
        expect(controller.show_save_and_return).to be_falsey
      end
    end
  end

  describe '#conditional_components_present?' do
    let(:page) { double(MetadataPresenter::Page) }

    before do
      allow(page).to receive(:conditional_components).and_return(conditional_components)
      controller.instance_variable_set(:@page, page)
    end

    context 'when there are no conditional components' do
      let(:conditional_components) { {} }

      it 'checks there are no conditional component' do
        expect(controller.conditional_components_present?).to be_falsey
      end
    end

    context 'when there are upload components' do
      let(:conditional_components) { %w[if or and] }

      it 'does not show save and return' do
        expect(controller.conditional_components_present?).to be_truthy
      end
    end
  end

  describe 'page title helper' do
    let(:page) { double(MetadataPresenter::Page) }
    let(:components) { [] }

    before do
      RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

      allow(page).to receive(:components).and_return(components)
      allow(page).to receive(:heading).and_return('hello')
      allow(page).to receive(:title).and_return('title')
      allow(page).to receive(:[])
      controller.instance_variable_set(:@page, page)
    end

    after do
      RSpec::Mocks.configuration.allow_message_expectations_on_nil = false
    end

    it 'shows the page title and service name in the title' do
      expect(controller.form_page_title).to eq('title - Version Fixture - GOV.UK')
    end

    context 'when the title is nil' do
      it 'shows the page heading if present and service name in the title' do
        allow(page).to receive(:title).and_return(nil)
        expect(controller.form_page_title).to eq('hello - Version Fixture - GOV.UK')
      end
    end

    context 'when there are components in the page' do
      context 'when the component has a label' do
        let(:components) { [{ 'label' => 'a label', 'legend' => 'a legend' }] }

        it 'uses the label in the title' do
          expect(controller.form_page_title).to eq('a label - Version Fixture - GOV.UK')
        end
      end

      context 'when the component has no label' do
        let(:components) { [{ 'legend' => 'a legend' }] }

        it 'uses the legend in the title' do
          expect(controller.form_page_title).to eq('a legend - Version Fixture - GOV.UK')
        end
      end

      context 'when the component has neither, becauase it is a content component' do
        let(:components) { [{ 'content' => 'some content' }] }

        it 'uses the page title in the title' do
          expect(controller.form_page_title).to eq('title - Version Fixture - GOV.UK')
        end

        it 'also uses the page heading in the title' do
          allow(page).to receive(:title).and_return(nil)
          expect(controller.form_page_title).to eq('hello - Version Fixture - GOV.UK')
        end
      end
    end

    context 'when no page' do
      let(:page) { nil }

      it 'shows the service name in the title' do
        expect(controller.form_page_title).to eq('Version Fixture - GOV.UK')
      end
    end

    context 'defaulting to the base title' do
      let(:page) { nil }
      let(:service_double) { double(MetadataPresenter::Service) }

      before do
        allow(service_double).to receive(:service_name).and_return(nil)
        allow(controller).to receive(:service).and_return(service_double)
      end

      it 'shows the default title' do
        expect(controller.form_page_title).to eq('MoJ Forms')
      end
    end
  end
end
