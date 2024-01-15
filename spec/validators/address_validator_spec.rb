RSpec.describe MetadataPresenter::AddressValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end

  let(:page) { service.find_page_by_url('/postal-address') }
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  describe '#valid?' do
    let(:address_line_one) { 'most beautiful road' }
    let(:address_line_two) { 'of the most beautiful hamlet' }
    let(:city) { 'far far from the city' }
    let(:county) { 'in a far far away county' }
    let(:postcode) { '999' }
    let(:country) { 'Great country' }

    let(:answers) do
      {
        component.id => {
          address_line_one:,
          address_line_two:,
          city:,
          county:,
          postcode:,
          country:
        }
      }
    end

    context 'when address fields are all filled properly' do
      it { expect(validator).to be_valid }
    end

    context 'when a required field is missing' do
      described_class::REQUIRED_FIELDS.each do |field|
        context "when #{field} is missing" do
          let(field) { '' }
          it { expect(validator).not_to be_valid }
        end
      end
    end

    context 'when an optional field is missing' do
      described_class::OPTIONAL_FIELDS.each do |field|
        context "when #{field} is missing" do
          let(field) { '' }
          it { expect(validator).to be_valid }
        end
      end
    end
  end
end
