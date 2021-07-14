RSpec.describe MetadataPresenter::Expression do
  subject(:expression) do
    described_class.new(attributes)
  end

  before do
    expression.service = service
  end

  describe '#field_label' do
    context 'when field is present' do
      let(:attributes) do
        {
          'page': '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
          'component': 'ac41be35-914e-4b22-8683-f5477716b7d4',
          'field': 'c5571937-9388-4411-b5fa-34ddf9bc4ca0'
        }
      end

      it 'returns field label' do
        expect(expression.field_label).to eq('Only on weekends')
      end
    end

    context 'when field is not present' do
      let(:attributes) do
        {
          'page': '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
          'component': 'ac41be35-914e-4b22-8683-f5477716b7d4',
          'field': ''
        }
      end

      it 'returns nil' do
        expect(expression.field_label).to be_nil
      end
    end
  end
end
