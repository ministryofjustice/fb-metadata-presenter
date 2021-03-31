RSpec.describe MetadataPresenter::NumberValidator do
  subject(:validator) do
    described_class.new(page_answers: page_answers, component: component)
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  describe '#validate' do
    before do
      validator.valid?
    end

    context 'when is not a number' do
      %w[centuries . $ # % , 1.a 2.b].each do |invalid_answer|
        let(:answers) { { 'your-age_number_1' => invalid_answer } }
        let(:page) { service.find_page_by_url('/your-age') }

        it "returns invalid for '#{invalid_answer}'" do
          expect(validator).to_not be_valid
        end
      end
    end

    context 'when is a number' do
      %w[1 1.1 100].each do |valid_answer|
        let(:answers) { { 'your-age_number_1' => valid_answer } }
        let(:page) { service.find_page_by_url('/your-age') }

        it "returns valid for '#{valid_answer}'" do
          expect(validator).to be_valid
        end
      end
    end
  end
end
