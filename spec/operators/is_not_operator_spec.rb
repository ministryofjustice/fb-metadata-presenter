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
end
