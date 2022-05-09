RSpec.describe MetadataPresenter::MinWordValidator do
  subject(:validator) do
    described_class.new(page_answers: page_answers, component: component)
  end
  let(:page) do
    meta = service.find_page_by_url('/family-hobbies')
    meta['components'][0]['validation'] = min_word_validation
    meta
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }
  let(:min_word_validation) { { 'min_word' => '10' } }

  describe '#valid?' do
    before do
      validator.valid?
    end

    context 'when answer is blank' do
      let(:answers) { { 'family-hobbies_textarea_1' => '' } }

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end

    context 'when user answer is present' do
      let(:answers) do
        {
          'family-hobbies_textarea_1' => "Zombie ipsum reversus ab viral inferno, nam Rick Grimes malum cerebro. De-carne lumbering animata corpora quaeritis. Summus brain's sit, morbo vel maleficia?"
        }
      end

      context 'when answer is higher than the minimum word count' do
        it 'returns valid' do
          expect(validator).to be_valid
        end
      end
      context 'when answer is lower than the minimum word count' do
        let(:min_word_validation) { { 'min_word' => '1000' } }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end
      end
    end
  end
end
