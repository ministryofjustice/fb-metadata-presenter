RSpec.describe MetadataPresenter::PageAnswers do
  subject(:page_answers) { described_class.new(answers) }

  describe '#method_missing' do
    context 'when the components exist in a page' do
      context 'when there are answers' do
        let(:answers) { { 'name_text_1' => 'Mando' } }

        it 'returns the value of the answer' do
          expect(page_answers.name_text_1).to eq('Mando')
        end
      end

      context 'when there are no answers' do
        let(:answers) { {} }

        it 'returns nil' do
          expect(page_answers.name_text_1).to be_nil
        end
      end
    end

    context 'when the components do not exist' do
      # This will be tested when we add multiple questions pages
    end
  end

  describe '#respond_to' do
    context 'when there are answers' do
      let(:answers) { { 'name_text_1' => 'Mando' } }

      it 'returns the value of the answer' do
        expect(page_answers.respond_to?(:name_text_1)).to be_truthy
      end
    end

    context 'when there are no answers' do
      let(:answers) { {} }

      it 'returns nil' do
        expect(page_answers.respond_to?(:name_text_1)).to be_falsey
      end
    end
  end
end
