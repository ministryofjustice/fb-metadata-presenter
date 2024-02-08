RSpec.describe MetadataPresenter::Page do
  describe '#==' do
    let(:page) { described_class.new({ _id: 'foo' }) }

    context 'when two pages are equal' do
      let(:other_page) { described_class.new({ _id: 'foo' }) }

      it 'returns true' do
        expect(page == other_page).to be_truthy
      end
    end

    context 'when two pages are different' do
      let(:other_page) { described_class.new({ _id: 'foobar' }) }

      it 'returns false' do
        expect(page == other_page).to be_falsey
      end
    end

    context 'when comparing different objects' do
      let(:other_object) { true }

      it 'returns false' do
        expect(page == other_object).to be_falsey
      end
    end
  end

  describe '#components' do
    it 'returns an array of Component objects' do
      components = service.pages.map(&:components).flatten.compact
      components.each do |component|
        expect(component).to be_kind_of(MetadataPresenter::Component)
        expect(component.collection).to eq(:components)
      end
    end
  end

  describe '#extra_components' do
    it 'returns an array of Component objects' do
      components = service.pages.map(&:extra_components).flatten.compact

      expect(components.size).to eq(1)

      components.each do |component|
        expect(component).to be_kind_of(MetadataPresenter::Component)
        expect(component.collection).to eq(:extra_components)
      end
    end
  end

  describe '#input_components' do
    let(:page) { service.find_page_by_url('star-wars-knowledge') }
    let(:expected_component_ids) { %w[star-wars-knowledge_radios_1 star-wars-knowledge_text_1] }

    it 'returns an array of only components that take user input' do
      component_ids = page.input_components.map(&:id)
      expect(component_ids).to eq(expected_component_ids)
      expect(component_ids).not_to include('star-wars-knowledge_content_1')
    end
  end

  describe '#content_components' do
    let(:page) { service.find_page_by_url('star-wars-knowledge') }

    it 'returns an array of only content components' do
      component_ids = page.content_components.map(&:id)
      expect(component_ids).to eq(%w[star-wars-knowledge_content_1])
      %w[star-wars-knowledge_text_1 star-wars-knowledge_radios_1].each do |id|
        expect(component_ids).not_to include(id)
      end
    end
  end

  describe '#editable_attributes' do
    it 'does not reject editable attributes' do
      expect(service.pages.first.editable_attributes.keys).to include(
        :heading,
        :body,
        :url
      )
    end

    it 'rejects all not editable attributes' do
      not_editable = MetadataPresenter::Page::NOT_EDITABLE
      attributes = not_editable.index_with { |_k| SecureRandom.uuid }
      page = MetadataPresenter::Page.new(attributes)

      expect(page.editable_attributes.keys).to_not include(not_editable)
    end
  end

  describe '#uuid' do
    it 'returns _uuid attribute' do
      expect(
        described_class.new({ _uuid: 'kylo-ren' }).uuid
      ).to eq('kylo-ren')
    end
  end

  describe '#to_partial_path' do
    subject(:page) { described_class.new({ _type: 'page.singlequestion' }) }

    it 'returns the type of the page' do
      expect(page.to_partial_path).to eq('page/singlequestion')
    end
  end

  describe '#supported_input_components' do
    context 'when page has input components' do
      subject(:page) { described_class.new({ _type: 'page.multiplequestions' }) }

      it 'returns the correct input components' do
        expect(page.supported_input_components).to match_array(%w[text textarea number date radios checkboxes email address])
      end
    end

    context 'when page does not have input components' do
      subject(:page) { described_class.new({ _type: 'page.checkanswers' }) }

      it 'returns an empty array' do
        expect(page.supported_input_components).to be_empty
      end
    end

    context 'when the page is not configured' do
      subject(:page) { described_class.new({ _type: 'page.boba-fett' }) }

      it 'raises a PageComponentsNotDefinedError' do
        expect {
          page.supported_input_components
        }.to raise_error(MetadataPresenter::PageComponentsNotDefinedError)
      end
    end
  end

  describe '#supported_content_components' do
    context 'when page has content components' do
      subject(:page) { described_class.new({ _type: 'page.multiplequestions' }) }

      it 'returns the correct content components' do
        expect(page.supported_content_components).to match_array(%w[content])
      end
    end

    context 'when the page is not configured' do
      subject(:page) { described_class.new({ _type: 'page.jar-jar-binks' }) }

      it 'raises a PageComponentsNotDefinedError' do
        expect {
          page.supported_content_components
        }.to raise_error(MetadataPresenter::PageComponentsNotDefinedError)
      end
    end
  end

  describe '#upload_components' do
    context 'when page has upload components' do
      subject(:page) { service.find_page_by_url('dog-picture') }

      it 'returns empty' do
        expect(page.upload_components).to match_array([page.components.first])
      end
    end

    context 'when page does not have upload components' do
      subject(:page) { service.find_page_by_url('name') }

      it 'returns empty' do
        expect(page.upload_components).to eq([])
      end
    end
  end

  describe '#find_component_by_uuid' do
    subject(:page) { service.find_page_by_url('name') }

    it 'returns component' do
      expect(
        page.find_component_by_uuid('27d377a2-6828-44ca-87d1-b83ddac98284')
      ).to eq(page.components.first)
    end
  end

  describe '#standalone?' do
    context 'when page is a standalone page' do
      subject(:page) { service.find_page_by_url('cookies') }

      it 'returns truthy' do
        expect(page.standalone?).to be_truthy
      end
    end

    context 'when page is not a standalone page' do
      subject(:page) { service.find_page_by_url('name') }

      it 'returns falsey' do
        expect(page.standalone?).to be_falsey
      end
    end
  end

  describe '#question_page?' do
    context 'when page has a question' do
      subject(:page) { service.find_page_by_url('name') }

      it 'returns truthy' do
        expect(page.question_page?).to be_truthy
      end
    end

    context 'when page does not have any questions' do
      subject(:page) { service.find_page_by_url('confirmation') }

      it 'returns falsey' do
        expect(page.question_page?).to be_falsey
      end
    end
  end

  describe '#title' do
    context 'when there is one component' do
      let(:page) { service.find_page_by_url('name') }

      it 'returns the correct title' do
        expect(page.title).to eq('Full name')
      end
    end

    context 'when there is more than one component' do
      let(:page) { service.find_page_by_url('star-wars-knowledge') }

      it 'returns the correct title' do
        expect(page.title).to eq('How well do you know Star Wars?')
      end
    end

    context 'when multiplequestions page with single component' do
      let(:page) do
        page_metadata = service_metadata['pages'].find { |page| page['url'] == 'star-wars-knowledge' }
        page_metadata['components'] = [page_metadata['components'].shift]
        MetadataPresenter::Page.new(page_metadata)
      end

      it 'returns the page title not the component title' do
        expect(page.title).to eq('How well do you know Star Wars?')
      end
    end

    context 'when the page is a content page' do
      let(:page) { service.find_page_by_url('how-many-lights') }

      it 'returns the correct title' do
        expect(page.title).to eq('Tell me how many lights you see')
      end
    end

    context 'when is check your answers' do
      let(:page) { service.find_page_by_url('check-answers') }

      it 'returns the correct title' do
        expect(page.title).to eq('Check your answers')
      end
    end

    context 'when there are no components' do
      let(:page) { service.find_page_by_url('/') }

      it 'returns the correct title' do
        expect(page.title).to eq('Service name goes here')
      end
    end

    context 'when page is an exit page' do
      let(:latest_metadata) { metadata_fixture(:branching_7) }
      let(:service) { MetadataPresenter::Service.new(latest_metadata) }
      let(:page) { service.find_page_by_url('page-g') }

      it 'returns the correct title' do
        expect(page.title).to eq('Page G')
      end
    end
  end

  describe '#end_of_route?' do
    context 'when the page is not the end of the route' do
      let(:page) { service.find_page_by_url('how-many-lights') }

      it 'returns falsey' do
        expect(page.end_of_route?).to be_falsey
      end
    end

    context 'when the page is the end of the route' do
      let(:page) { service.find_page_by_url('confirmation') }

      it 'returns truthy' do
        expect(page.end_of_route?).to be_truthy
      end
    end
  end

  describe '#multiple_questions?' do
    context 'when page is a multiple question page' do
      subject(:page) { service.find_page_by_url('star-wars-knowledge') }

      it 'returns truthy' do
        expect(page.multiple_questions?).to be_truthy
      end
    end

    context 'when page is not a multiple questions page' do
      subject(:page) { service.find_page_by_url('name') }

      it 'returns falsey' do
        expect(page.multiple_questions?).to be_falsey
      end
    end
  end

  describe '#autocomplete_component_present?' do
    context 'when there is an autocomplete component' do
      subject(:page) { service.find_page_by_url('countries') }

      it 'returns true' do
        expect(page.autocomplete_component_present?).to be_truthy
      end
    end

    context 'when there is no autocomplete component' do
      subject(:page) do
        service.find_page_by_url('dog-picture')
      end

      it 'returns false' do
        expect(page.autocomplete_component_present?).to be_falsey
      end
    end
  end

  describe '#assign_autocomplete_items' do
    subject(:page) { service.find_page_by_url('countries') }
    let(:component_id) { page.components.first.uuid }
    let(:items) do
      {
        component_id => [{ 'text' => 'abc', 'value' => '123' }]
      }
    end

    before do
      page.assign_autocomplete_items(items)
    end

    it 'sets the autocomplete items' do
      expected_items = page.components.first.items
      expect(expected_items).to all(be_an(MetadataPresenter::AutocompleteItem))
      expect(expected_items.first.text).to eq('abc')
      expect(expected_items.first.value).to eq('123')
    end
  end

  describe '#contains_placeholders?' do
    context 'when page has placeholders' do
      subject(:page) { service.find_page_by_url('privacy') }

      before do
        allow(page).to receive(:placeholders).and_return(['[Name of your form or service]', '[insert contact details]'])
      end

      it 'returns true' do
        expect(page.contains_placeholders?).to be true
      end
    end

    context 'when page has no placeholders' do
      subject(:page) { service.find_page_by_url('countries') }

      before do
        allow(page).to receive(:placeholders).and_return([])
      end

      it 'returns false' do
        expect(page.contains_placeholders?).to be false
      end
    end
  end

  describe '#placeholders' do
    context 'when placeholders key exists' do
      subject(:page) { service.find_page_by_url('privacy') }

      before do
        allow(I18n).to receive(:t).with('presenter.footer.privacy.placeholders', raise: true).and_return(['[insert your organization name]', '[your organisation]'])
      end

      it 'returns placeholders from translations' do
        expect(page.placeholders).to eq ['[insert your organization name]', '[your organisation]']
      end
    end

    context 'when placeholders key doesn\'t exist' do
      subject(:page) { service.find_page_by_url('cookies') }

      before do
        allow(I18n).to receive(:t).with('presenter.footer.cookies.placeholders', raise: true).and_raise(I18n::MissingTranslationData.new('en', 'presenter.footer.privacy.placeholders'))
      end

      it 'returns placeholders from translations' do
        expect(page.placeholders).to eq []
      end
    end
  end

  describe 'Conditional Content and Components' do
    let(:service_metadata) { metadata_fixture(:conditional_content) }
    let(:page) { service.find_page_by_url('content') }
    let(:user_data) do
      {
        'multiple_radios_1' => 'Option A',
        'multiple_checkboxes_1' => %w[2]
      }
    end

    context '#load_conditional_content' do
      let(:expected_components) do
        %w[
          701f93e3-1d78-4a1f-9495-07e32b6e26fe
          71bfc176-613d-42ec-8d53-63e50b696ec6
          61139d00-53eb-4ff3-9227-6ecd0b80aac4
          4d4d7ace-9ce2-4415-9edb-abcac75ed17b
          6a3b4104-1d4c-4534-87d8-b81f5c764d43
        ]
      end

      before do
        page.load_conditional_content(service, user_data)
      end

      it 'should return the right number of always display component' do
        expect(page.conditional_content_to_show).to eq(expected_components)
      end

      it 'should show conditional component' do
        expect(page.show_conditional_component?('701f93e3-1d78-4a1f-9495-07e32b6e26fe')).to be_truthy
      end
    end

    context '#conditional_components' do
      let(:expected_components) do
        %w[
          1ed7161c-b712-429c-b647-edd39f71b39f
          2e8d0ad4-5640-4cd5-815c-4f4116a685d5
          701f93e3-1d78-4a1f-9495-07e32b6e26fe
          71bfc176-613d-42ec-8d53-63e50b696ec6
          37a83516-20c3-4208-ae5f-752038113742
          5ccc3681-4aa5-447a-8763-6fcdd257bfcc
          61139d00-53eb-4ff3-9227-6ecd0b80aac4
          4d4d7ace-9ce2-4415-9edb-abcac75ed17b
          75fd4dd0-2be1-44d0-9153-d7ec5ceb2a55
          b23d885d-5326-49f2-b4f4-5ac5d53a03da
        ]
      end

      it 'should include the conditional components uuids' do
        expect(Set.new(page.conditional_components)).to eq(Set.new(expected_components))
      end
    end
  end
end
