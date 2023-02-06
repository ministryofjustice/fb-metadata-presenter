RSpec.describe MetadataPresenter::AutocompleteValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:, autocomplete_items:)
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers, autocomplete_items) }
  let(:page) { service.find_page_by_url('/countries') }
  let(:component_id) { page.components.first.uuid }
  let(:autocomplete_items) do
    {
      component_id.to_s => [
        { 'text' => 'Afghanistan', 'value' => 'AF' },
        { 'text' => 'Albania', 'value' => 'AL' },
        { 'text' => 'Australia', 'value' => 'AU' }
      ]
    }
  end

  describe '#valid?' do
    before do
      validator.valid?
    end

    context 'when answer is invalid' do
      let(:answers) do
        { 'countries_autocomplete_1' => '{"text":"Japan","value":"JP"}' }
      end

      it 'returns invalid' do
        expect(validator).to_not be_valid
      end
    end

    context 'when answer is valid' do
      let(:answers) do
        { 'countries_autocomplete_1' => '{"text":"Australia","value":"AU"}' }
      end

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end

    context 'when there are no autocomplete items' do
      let(:autocomplete_items) { {} }
      let(:answers) do
        { 'countries_autocomplete_1' => '{"text":"Australia","value":"AU"}' }
      end

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end

    context 'when there are no items for the component' do
      let(:component_id) { SecureRandom.uuid }
      let(:answers) do
        { 'countries_autocomplete_1' => '{"text":"Australia","value":"AU"}' }
      end

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end
  end
end
