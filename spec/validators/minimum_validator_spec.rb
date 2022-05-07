RSpec.describe MetadataPresenter::MinimumValidator do
  subject(:validator) do
    described_class.new(page_answers: page_answers, component: component)
  end
  let(:page) do
    meta = service.find_page_by_url('/your-age')
    meta['components'][0]['validation'] = minimum_validation
    meta
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }
  let(:minimum_validation) { { 'minimum' => '5' } }

  describe '#validate' do
    before do
      validator.valid?
    end

    context 'when invalid answer' do
      %w[1 1.1 0.5].each do |invalid_answer|
        let(:answers) { { 'your-age_number_1' => invalid_answer } }

        it "returns invalid for '#{invalid_answer}'" do
          expect(validator).to_not be_valid
        end
      end
    end

    context 'when valid answer' do
      %w[5 5.6 100].each do |valid_answer|
        let(:answers) { { 'your-age_number_1' => valid_answer } }

        it "returns valid for '#{valid_answer}'" do
          expect(validator).to be_valid
        end
      end
    end
  end
end
