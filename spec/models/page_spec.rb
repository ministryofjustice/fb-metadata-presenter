RSpec.describe MetadataPresenter::Page do
  describe '#==' do
    let(:page) { described_class.new(_id: 'foo') }

    context 'when two pages are equal' do
      let(:other_page) { described_class.new(_id: 'foo') }

      it 'returns true' do
        expect(page == other_page).to be_truthy
      end
    end

    context 'when two pages are different' do
      let(:other_page) { described_class.new(_id: 'foobar') }

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

  describe '#editable_attributes' do
    it 'does not reject editable attributes' do
      expect(service.pages.first.editable_attributes.keys).to include(
        :heading,
        :body,
        :lede,
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
        described_class.new(_uuid: 'kylo-ren').uuid
      ).to eq('kylo-ren')
    end
  end

  describe '#to_partial_path' do
    subject(:page) { described_class.new(_type: 'page.singlequestion') }

    it 'returns the type of the page' do
      expect(page.to_partial_path).to eq('page/singlequestion')
    end
  end

  describe '#input_components' do
    context 'when page has input components' do
      subject(:page) { described_class.new(_type: 'page.multiplequestions') }

      it 'returns the correct input components' do
        expect(page.input_components).to match_array(%w[text textarea number date radios checkboxes])
      end
    end

    context 'when page does not have input components' do
      subject(:page) { described_class.new(_type: 'page.checkanswers') }

      it 'returns an empty array' do
        expect(page.input_components).to be_empty
      end
    end

    context 'when the page is not configured' do
      subject(:page) { described_class.new(_type: 'page.boba-fett') }

      it 'raises a PageComponentsNotDefinedError' do
        expect {
          page.input_components
        }.to raise_error(MetadataPresenter::PageComponentsNotDefinedError)
      end
    end
  end

  describe '#content_components' do
    context 'when page has content components' do
      subject(:page) { described_class.new(_type: 'page.multiplequestions') }

      it 'returns the correct content components' do
        expect(page.content_components).to match_array(%w[content])
      end
    end

    context 'when the page is not configured' do
      subject(:page) { described_class.new(_type: 'page.jar-jar-binks') }

      it 'raises a PageComponentsNotDefinedError' do
        expect {
          page.content_components
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
end
