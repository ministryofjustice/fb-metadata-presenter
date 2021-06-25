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

  describe '#evaluate_collection?' do
    context 'when is answered' do
      let(:expected) { %w[foo] }

      it 'returns false' do
        expect(operator.evaluate_collection?).to be_falsey
      end
    end

    context 'when is not answered' do
      let(:expected) { [] }

      it 'returns true' do
        expect(operator.evaluate_collection?).to be_truthy
      end
    end

    context 'when is nil' do
      let(:expected) { nil }

      it 'returns true' do
        expect(operator.evaluate_collection?).to be_truthy
      end
    end
  end
end
