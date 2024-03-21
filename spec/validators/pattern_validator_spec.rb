RSpec.describe MetadataPresenter::PatternValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end
  let(:page) do
    meta = service.find_page_by_url('/name')
    meta['components'][0]['validation'] = pattern_validation
    meta
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }
  let(:pattern_validation) { { 'pattern' => '\D+' } }

  describe '#valid?' do
    before do
      validator.valid?
    end

    context 'when answer match pattern' do
      let(:answers) { { 'name_text_1' => 'Jane' } }
      it 'returns valid' do
        expect(validator).to be_valid
      end
    end

    context 'when answer does not match pattern' do
      let(:answers) { { 'name_text_1' => '123' } }

      it 'returns valid' do
        expect(validator).to_not be_valid
      end
    end

    context 'when answer is blank' do
      let(:answers) { { 'name_text_1' => '' } }

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end
  end
end
