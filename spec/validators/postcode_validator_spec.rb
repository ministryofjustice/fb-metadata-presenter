RSpec.describe MetadataPresenter::PostcodeValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end

  let(:page) { service.find_page_by_url('/postal-address') }
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  let(:postcode) { 'SW1H 9EA' }
  let(:country) { 'United Kingdom' }

  let(:answers) do
    {
      component.id => {
        postcode:,
        country:
      }.stringify_keys
    }
  end

  describe '#valid?' do
    context 'when postcode is not entered' do
      let(:postcode) { '' }

      it { expect(validator).to be_valid }
    end

    context 'when country is not one of the validatable countries' do
      let(:country) { 'Denmark' }

      it { expect(validator).to be_valid }
    end

    context 'when country is one of the validatable countries' do
      context 'when postcode is in a valid format' do
        it { expect(validator).to be_valid }
      end

      context 'when country is lowercase but validatable, it still triggers validation' do
        let(:country) { 'uk' }
        let(:postcode) { 'XY1 2EN' } # invalid postcode

        it { expect(validator).not_to be_valid }
      end

      context 'when postcode is not in a valid format' do
        let(:postcode) { 'XY1 2EN' } # invalid postcode

        it { expect(validator).not_to be_valid }
      end
    end
  end

  context 'error messages' do
    let(:postcode) { 'XY1 2EN' } # invalid postcode
    let(:expected_error) { 'Enter a valid UK postcode for "Confirm your postal address"' }

    before do
      validator.valid?
    end

    it 'adds an error to the page answers' do
      expect(
        page_answers.errors[:'postal-address_address_1.postcode']
      ).to include(expected_error)
    end

    it 'adds an error to user answer' do
      expect(
        subject.user_answer.errors[:postcode]
      ).to include(expected_error)
    end
  end
end
