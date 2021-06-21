RSpec.describe MetadataPresenter::IsOperator do
  subject(:operator) { described_class.new(actual, expected) }

  describe '#evaluate?' do
    context 'when equal' do
      let(:actual) { 'foo' }
      let(:expected) { 'foo' }

      it 'returns true' do
        expect(operator.evaluate?).to be_truthy
      end
    end

    context 'when different' do
      let(:actual) { 'foo' }
      let(:expected) { 'bar' }

      it 'returns false' do
        expect(operator.evaluate?).to be_falsey
      end
    end
  end
end
