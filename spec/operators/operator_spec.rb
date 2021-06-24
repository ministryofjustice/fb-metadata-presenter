RSpec.describe MetadataPresenter::Operator do
  subject { described_class.new(operator) }

  describe '#evaluate' do
    let(:actual) { double }
    let(:expected) { double }

    context 'when operator exists' do
      context 'when simple operator' do
        let(:operator) { 'is' }

        it 'expects to evaluate the operator' do
          expect_any_instance_of(MetadataPresenter::IsOperator).to receive(:evaluate?)
          subject.evaluate(actual, expected)
        end
      end

      context 'when operator name has two words' do
        let(:operator) { 'is_answered' }

        it 'expects to evaluate the operator' do
          expect_any_instance_of(MetadataPresenter::IsAnsweredOperator).to receive(:evaluate?)
          subject.evaluate(actual, expected)
        end
      end
    end

    context 'when operator does not exist' do
      let(:operator) { 'this-does-not-exist' }

      it 'raises no operator error' do
        expect {
          subject.evaluate(actual, expected)
        }.to raise_error(MetadataPresenter::NoOperator)
      end
    end
  end
end
