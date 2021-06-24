RSpec.describe MetadataPresenter::IsNotAnsweredOperator do
  subject(:operator) { described_class.new(actual, expected) }
  let(:actual) { 'Optional field' }

  describe '#evaluate?' do
    context 'when present' do
      let(:expected) { 'foo' }

      it 'returns false' do
        expect(operator.evaluate?).to be_falsey
      end
    end

    context 'when empty' do
      let(:expected) { '' }

      it 'returns true' do
        expect(operator.evaluate?).to be_truthy
      end
    end

    context 'when nil' do
      let(:expected) { nil }

      it 'returns true' do
        expect(operator.evaluate?).to be_truthy
      end
    end
  end
end
