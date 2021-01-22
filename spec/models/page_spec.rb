RSpec.describe MetadataPresenter::Page do
  describe '#validate_answers' do
    let(:page) { described_class.new(_id: 'foo') }

    before do
      expect_any_instance_of(
        MetadataPresenter::ValidateAnswers
      ).to receive(:valid?).and_return(valid)
    end

    context 'when valid' do
      let(:valid) { true }

      it 'returns true' do
        expect(page.validate_answers({})).to be_truthy
      end
    end

    context 'when invalid' do
      let(:valid) { false }

      it 'returns false' do
        expect(page.validate_answers({})).to be_falsey
      end
    end
  end

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

  context 'when creating a new service object' do
    it '#components should return an array of Component objects' do
    components = service.pages.map(&:components).flatten.compact
      components.each do |component|
        expect(component).to be_kind_of(MetadataPresenter::Component)
      end
    end
  end

  describe '#editable_attributes' do
    it 'rejects non editable attributes' do
      expect(service.pages.first.editable_attributes.keys).to include(
        :heading,
        :body,
        :lede,
        :url
      )
    end
  end

  describe '#to_partial_path' do
    subject(:page) { described_class.new(_type: 'page.singlequestion') }

    it 'returns the type of the page' do
      expect(page.to_partial_path).to eq('page/singlequestion')
    end
  end
end
