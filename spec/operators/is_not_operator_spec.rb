RSpec.describe MetadataPresenter::IsNotOperator do
  subject(:operator) { described_class.new(actual, expected) }

  describe '#evaluate?' do
    context 'when equal' do
      let(:actual) { 'foo' }
      let(:expected) { 'foo' }

      it 'returns false' do
        expect(operator.evaluate?).to be_falsey
      end
    end

    context 'when different' do
      let(:actual) { 'foo' }
      let(:expected) { 'bar' }

      it 'returns false' do
        expect(operator.evaluate?).to be_truthy
      end
    end
  end

  describe '#evaluate_collection?' do
    context 'when is included' do
      let(:actual) { 'Apples' }
      let(:expected) { %w[Apples] }

      it 'returns false' do
        expect(operator.evaluate_collection?).to be_falsey
      end
    end

    context 'when is not included' do
      context 'when other choices are selected' do
        let(:actual) { 'Apples' }
        let(:expected) { %w[Pears] }

        it 'returns true' do
          expect(operator.evaluate_collection?).to be_truthy
        end
      end

      context 'when is not answered' do
        let(:actual) { 'Apples' }
        let(:expected) { [] }

        it 'returns true' do
          expect(operator.evaluate_collection?).to be_truthy
        end
      end

      context 'when is nil' do
        let(:actual) { 'Apples' }
        let(:expected) { nil }

        it 'returns true' do
          expect(operator.evaluate_collection?).to be_truthy
        end
      end
    end
  end
end
