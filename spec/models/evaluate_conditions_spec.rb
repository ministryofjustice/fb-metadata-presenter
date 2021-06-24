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

    context 'when simple if condition' do
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
          expect(page).to eq(service.find_page_by_url('favourite-fruit'))
        end
      end
    end

    context 'when simple if/else' do
      let(:flow) { service.flow('ffadeb22-063b-4e4f-9502-bd753c706b1d') }
      context 'when apple criteria is met' do
        let(:user_data) do
          {
            'favourite-fruit_radios_1' => 'Apples'
          }
        end

        it 'returns the page uuid for the branching' do
          expect(page).to eq(service.find_page_by_url('apple-juice'))
        end

        context 'when orange criteria is met' do
          let(:user_data) do
            {
              'favourite-fruit_radios_1' => 'Oranges'
            }
          end

          it 'returns the page uuid for the branching' do
            expect(page).to eq(service.find_page_by_url('orange-juice'))
          end
        end

        context 'when none of the conditions are met' do
          let(:user_data) do
            {
              'favourite-fruit_radios_1' => 'Pears'
            }
          end

          it 'returns the page uuid for the default page' do
            expect(page).to eq(service.find_page_by_url('favourite-band'))
          end
        end
      end
    end

    context 'when the question is optional' do
      let(:flow) { service.flow('ffadeb22-063b-4e4f-9502-bd753c706b1d') }
      let(:user_data) { {} }

      it 'returns the page uuid for the default page' do
        expect(page).to eq(service.find_page_by_url('favourite-band'))
      end
    end
  end
end
