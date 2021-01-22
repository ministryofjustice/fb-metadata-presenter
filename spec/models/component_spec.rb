RSpec.describe MetadataPresenter::Component do
  subject(:component) { described_class.new(attributes) }

  describe '#to_partial_path' do
    let(:attributes) { { '_type' => 'email' } }

    it 'returns type' do
      expect(component.to_partial_path).to eq(
        'metadata_presenter/component/email'
      )
    end
  end
end
