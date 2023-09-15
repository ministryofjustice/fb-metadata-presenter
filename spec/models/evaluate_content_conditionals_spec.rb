RSpec.describe MetadataPresenter::EvaluateContentConditionals do
  subject(:evaluate_content_conditionals) do
    described_class.new(
      service:,
      component:,
      user_data:
    )
  end
  let(:service_metadata) { metadata_fixture(:conditional) }

  describe '#show_component' do
    subject(:show_component) { evaluate_content_conditionals.show_component }

    context 'when the question is a checkbox' do
      let(:component) { service.find_page_by_url('flavours').components.last }

      context 'when single expression is met' do
        let(:user_data) do
          {
            'ice-cream_checkboxes_1' => ['Chocolate', 'Hokey Pokey']
          }
        end

        it 'returns the content component uuid' do
          expect(show_component).to eq(component.uuid)
        end
      end

      context 'when multiple conditions are met' do
        let(:component) { service.find_page_by_url('flavours').components.first }
        let(:user_data) do
          {
            'ice-cream_checkboxes_1' => ['Chocolate', 'Hokey Pokey', 'Mango', 'Pistachio']
          }
        end

        it 'returns the content component uuid' do
          expect(show_component).to eq(component.uuid)
        end
      end

      context 'when conditions are not met' do
        let(:user_data) do
          {
            'ice-cream_checkboxes_1' => %w[Mango]
          }
        end

        it 'does not return the content component uuid' do
          expect(show_component).to eq(nil)
        end
      end
    end

    context 'when the question is a radio' do
      let(:component) { service.find_page_by_url('show-colours').components.first }

      context 'when yellow condition is met' do
        let(:user_data) do
          {
            'colours_radios_1' => 'yellow'
          }
        end

        it 'returns the component uuid' do
          expect(show_component).to eq(component.uuid)
        end
      end

      context 'when red condition is met' do
        let(:component) { service.find_page_by_url('show-colours').components.last }
        let(:user_data) do
          {
            'colours_radios_1' => 'red'
          }
        end

        it 'returns the component uuid' do
          expect(show_component).to eq(component.uuid)
        end
      end

      context 'when none of the conditions are met' do
        let(:user_data) do
          {
            'colours_radios_1' => 'blue'
          }
        end

        it 'returns the component uuid' do
          expect(show_component).to eq(nil)
        end
      end
    end

    context 'when multiple conditionals' do
      context 'when multiple expressions with "OR" statement' do
        let(:component) { service.find_page_by_url('show-colours').components.last }

        context 'when choosing one option' do
          let(:user_data) do
            {
              'ice-cream_checkboxes_1' => %w[Chocolate]
            }
          end

          it 'returns the component uuid' do
            expect(show_component).to eq(component.uuid)
          end
        end

        context 'when choosing another option' do
          let(:user_data) do
            {
              'colours_radios_1' => 'red'
            }
          end

          it 'returns the component uuid' do
            expect(show_component).to eq(component.uuid)
          end
        end

        context 'when choosing one option' do
          let(:user_data) do
            {
              'ice-colours_radios_1' => 'blue'
            }
          end

          it 'returns the component uuid' do
            expect(show_component).to eq(nil)
          end
        end
      end

      context 'when multiple expressions with "AND" statement' do
        let(:component) { service.find_page_by_url('flavours').components.first }

        context 'when the expressions are met' do
          let(:user_data) do
            {
              'ice-cream_checkboxes_1' => ['Chocolate', 'Mango', 'Hokey Pokey', 'Pistachio']
            }
          end

          it 'returns the content component uuid' do
            expect(show_component).to eq(component.uuid)
          end
        end

        context 'when the expressions are not met' do
          let(:user_data) do
            {
              'ice-cream_checkboxes_1' => %w[Chocolate Mango]
            }
          end

          it 'returns the content component uuid' do
            expect(show_component).to eq(nil)
          end
        end
      end
    end

    context 'when the question is optional' do
      context 'and the question is unanswered' do
        let(:component) { service.find_page_by_url('show-colours').components.first }
        let(:user_data) do
          {
            'colours_radios_1' => ''
          }
        end

        it 'does not show the conditional component' do
          expect(show_component).to eq(nil)
        end
      end
    end
  end
end
