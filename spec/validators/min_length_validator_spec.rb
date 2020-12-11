RSpec.describe MetadataPresenter::MinLengthValidator do
  subject(:validator) do
    described_class.new(page: page, answers: answers)
  end
  let(:service) { MetadataPresenter::Service.new(service_metadata) }
  let(:service_metadata) do
    JSON.parse(
      File.read(
        MetadataPresenter::Engine.root.join('spec', 'fixtures', 'version.json')
      )
    )
  end

  describe '#valid?' do
    before do
      validator.valid?
    end

    context 'when minimum length is invalid' do
      let(:answers) { {'full_name' => 'T' } }

      context 'when there is no custom error message' do
        let(:page) { service.find_page('/name') }

        it 'returns invalid' do
          expect(validator).to_not be_valid
        end

        it 'uses the default error message' do
          expect(page.errors.full_messages).to eq(
            ["Your answer for 'Full name' is too short (2 characters at least)"]
          )
        end
      end

      context 'when there is a custom error message' do
        let(:page) { service.find_page('/email-address') }
        let(:answers) do
          { 'email_address' => 'g' }
        end

        it 'uses the custom error message' do
          expect(page.errors.full_messages).to eq(
            ['Your email address is too short.']
          )
        end
      end
    end

    context 'when minimum length is valid' do
      let(:answers) { {'full_name' => 'Gandalf' } }
      let(:page) { service.find_page('/name') }

      it 'returns no errors' do
        expect(page.errors.full_messages).to eq([])
      end
    end
  end
end
