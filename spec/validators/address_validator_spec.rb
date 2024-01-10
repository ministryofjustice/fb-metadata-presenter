RSpec.describe MetadataPresenter::AddressValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end

  let(:page) { service.find_page_by_url('/postal-address') }
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  describe '#valid?' do
    let(:first_line) { 'most beautiful road' }
    let(:second_line) { 'of the most beautiful hamlet' }
    let(:city_line) { 'far far from the city' }
    let(:county_line) { 'in a far far away county' }
    let(:postcode_line) { '999' }
    let(:country_line) { 'Great country' }

    let(:answers) do
      {
        address_line_one: first_line,
        address_line_two: second_line,
        city: city_line,
        county: county_line,
        postcode: postcode_line,
        country: country_line
      }
    end

    context 'when address fields are all filled properly' do
      it 'is valid' do
        expect(validator.valid?).to be_truthy
      end
    end

    context 'when a required field is missing' do
      %i[first_line city_line postcode_line country_line].each do |field|
        context "when #{field} is missing" do
          let(field) { '' }
          it 'returns invalid' do
            expect(validator.valid?).to be_falsey
          end
        end
      end
    end

    context 'when a optional field is missing' do
      %i[second_line county_line].each do |field|
        context "when #{field} is missing" do
          let(field) { '' }
          it 'returns valid' do
            expect(validator.valid?).to be_truthy
          end
        end
      end
    end
  end
end
