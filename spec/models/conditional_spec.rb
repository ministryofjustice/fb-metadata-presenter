RSpec.describe MetadataPresenter::Conditional do
  subject(:conditional) { described_class.new(attributes) }

  describe '#expression' do
    context 'when there are expressions' do
      let(:attributes) do
        {
          expressions: [
            {
              operator: 'is'
            }
          ]
        }
      end

      it 'returns the expressions' do
        expect(conditional.expressions).to eq(
          [MetadataPresenter::Expression.new(operator: 'is')]
        )
      end
    end

    context 'when there are no expressions' do
      let(:attributes) { { this_is_the_way: 'I lied' } }

      it 'returns empty' do
        expect(conditional.expressions).to eq([])
      end
    end
  end
end
