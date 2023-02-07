RSpec.describe MetadataPresenter::EvaluateConditionals do
  subject(:evaluate_conditionals) do
    described_class.new(
      service:,
      flow:,
      user_data:
    )
  end
  let(:service_metadata) { metadata_fixture(:branching) }

  describe '#page' do
    subject(:page) { evaluate_conditionals.page }

    context 'when simple if conditional' do
      let(:flow) { service.flow_object('09e91fd9-7a46-4840-adbc-244d545cfef7') }

      context 'when expressions are met' do
        let(:user_data) do
          {
            'do-you-like-star-wars_radios_1' => 'Only on weekends'
          }
        end

        it 'returns the page uuid for the branching' do
          expect(page).to eq(service.find_page_by_url('star-wars-knowledge'))
        end
      end

      context 'when expressions are not met' do
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
      let(:flow) { service.flow_object('ffadeb22-063b-4e4f-9502-bd753c706b1d') }
      context 'when apple expression is met' do
        let(:user_data) do
          {
            'favourite-fruit_radios_1' => 'Apples'
          }
        end

        it 'returns the page uuid for the branching' do
          expect(page).to eq(service.find_page_by_url('apple-juice'))
        end

        context 'when orange expression is met' do
          let(:user_data) do
            {
              'favourite-fruit_radios_1' => 'Oranges'
            }
          end

          it 'returns the page uuid for the branching' do
            expect(page).to eq(service.find_page_by_url('orange-juice'))
          end
        end

        context 'when none of the conditionals are met' do
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

      context 'when the question is a checkbox component' do
        let(:flow) { service.flow_object('618b7537-b42b-4551-ae7d-053afa4d9ca9') }

        context 'when beef cheese and tomato conditional "is" met' do
          let(:user_data) do
            {
              'burgers_checkboxes_1' => ['Beef, cheese, tomato']
            }
          end

          it 'returns the page uuid for the default page' do
            expect(page).to eq(service.find_page_by_url('global-warming'))
          end
        end

        context 'when beef cheese and tomator "is not" met' do
          let(:user_data) do
            {
              'burgers_checkboxes_1' => ['Chicken, cheese, tomato']
            }
          end

          it 'returns the page uuid for the default page' do
            expect(page).to eq(service.find_page_by_url('we-love-chickens'))
          end
        end
      end
    end

    context 'when the question is optional' do
      context 'for single answer questions' do
        let(:flow) { service.flow_object('ffadeb22-063b-4e4f-9502-bd753c706b1d') }
        let(:user_data) { { 'favourite-fruit_radios_1' => '' } }

        it 'returns the page uuid for the default page' do
          expect(page).to eq(service.find_page_by_url('favourite-band'))
        end
      end

      context 'for multiple answer (checkboxes) questions' do
        let(:flow) { service.flow_object('ffadeb22-063b-4e4f-9502-bd753c706b1d') }
        let(:user_data) { { 'burgers_checkboxes_1' => [] } }

        it 'returns the page uuid for the default page' do
          expect(page).to eq(service.find_page_by_url('favourite-band'))
        end
      end
    end

    context 'when multiple conditionals' do
      let(:flow) { service.flow_object('84a347fc-8d4b-486a-9996-6a86fa9544c5') }

      context 'when multiple expressions with "OR" statement' do
        context 'when the conditionals are met' do
          context 'when choosing one option' do
            let(:user_data) do
              { 'marvel-series_radios_1' => 'Loki' }
            end

            it 'returns the page that evaluates the conditional' do
              expect(page).to eq(service.find_page_by_url('marvel-quotes'))
            end
          end

          context 'when choosing another option from the conditional' do
            let(:user_data) do
              { 'marvel-series_radios_1' => 'The Falcon and the Winter Soldier' }
            end

            it 'returns the page that evaluates the conditional' do
              expect(page).to eq(service.find_page_by_url('marvel-quotes'))
            end
          end
        end

        context 'when the conditionals are not met' do
          let(:user_data) do
            { 'marvel-series_radios_1' => 'Other' }
          end

          it 'returns the page that evaluates the conditional' do
            expect(page).to eq(service.find_page_by_url('best-arnold-quote'))
          end
        end
      end

      context 'when multiple expressions with "AND" statement' do
        context 'when the conditionals are met' do
          let(:user_data) do
            {
              'do-you-like-star-wars_radios_1' => 'Only on weekends',
              'marvel-series_radios_1' => 'WandaVision'
            }
          end

          it 'returns the page that evaluates the conditional' do
            expect(page).to eq(service.find_page_by_url('other-quotes'))
          end
        end

        context 'when the conditionals are not met' do
          context 'when one expression is met but not the other' do
            let(:user_data) do
              { 'marvel-series_radios_1' => 'WandaVision' }
            end

            it 'returns the page default' do
              expect(page).to eq(service.find_page_by_url('best-arnold-quote'))
            end
          end
        end
      end
    end
  end
end
