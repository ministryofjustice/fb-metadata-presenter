RSpec.describe MetadataPresenter::EvaluateConditions do
  subject(:evaluate_conditions) do
    described_class.new(
      service: service,
      flow: flow,
      user_data: user_data
    )
  end
  let(:service_metadata) { metadata_fixture(:branching) }

  describe '#page' do
    subject(:page) { evaluate_conditions.page  }

    context 'when simple if else' do
      let(:flow) { service.flow('09e91fd9-7a46-4840-adbc-244d545cfef7') }

      context 'when criterias are met' do
        let(:user_data) do
          {
            'do-you-like-star-wars_radios_1' => 'Only on weekends'
          }
        end

        it 'returns the page uuid for the branching' do
          expect(page).to eq(service.find_page_by_url('star-wars-knowledge'))
        end
      end

      context 'when criterias are not met' do
        let(:user_data) do
          {
            'do-you-like-star-wars_radios_1' => 'Hell no!'
          }
        end

        it 'returns default next page' do
          expect(page).to eq(service.find_page_by_url('check-answers'))
        end
      end
    end
  end
end
