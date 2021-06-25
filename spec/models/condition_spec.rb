RSpec.describe MetadataPresenter::Condition do
  subject(:condition) { described_class.new(attributes) }

  describe '#criterias' do
    context 'when there are criterias' do
      let(:attributes) do
        {
          criterias: [
            {
              operator: 'is'
            }
          ]
        }
      end

      it 'returns the criterias' do
        expect(condition.criterias).to eq(
          [MetadataPresenter::Criteria.new(operator: 'is')]
        )
      end
    end

    context 'when there are no criterias' do
      let(:attributes) { { this_is_the_way: 'I lied' } }

      it 'returns empty' do
        expect(condition.criterias).to eq([])
      end
    end
  end
end
