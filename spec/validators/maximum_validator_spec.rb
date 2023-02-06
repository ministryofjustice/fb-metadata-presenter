RSpec.describe MetadataPresenter::MaximumValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end
  let(:page) do
    meta = service.find_page_by_url('/your-age')
    meta['components'][0]['validation'] = maximum_validation
    meta
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }
  let(:maximum_validation) { { 'maximum' => '5' } }

  describe '#validate' do
    before do
      validator.valid?
    end

    context 'when invalid answer' do
      %w[5.6 100].each do |invalid_answer|
        let(:answers) { { 'your-age_number_1' => invalid_answer } }

        it "returns invalid for '#{invalid_answer}'" do
          expect(validator).to_not be_valid
        end
      end
    end

    context 'when valid answer' do
      %w[0.1 1 3.2 5].each do |valid_answer|
        let(:answers) { { 'your-age_number_1' => valid_answer } }

        it "returns valid for '#{valid_answer}'" do
          expect(validator).to be_valid
        end
      end
    end

    context 'when not a number' do
      let(:answers) { { 'your-age_number_1' => 'i am not a number' } }

      it 'returns valid' do
        expect(validator).to be_valid
      end
    end
  end
end
