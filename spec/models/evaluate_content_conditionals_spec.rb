RSpec.describe MetadataPresenter::EvaluateContentConditionals do
  subject(:evaluate_content_conditionals) do
    described_class.new(
      service:,
      candidate_component: component,
      user_data:
    )
  end

  describe '#show_component' do
    let(:service_metadata) { metadata_fixture(:conditional) }
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

  describe '#uuids_to_include' do
    let(:service_metadata) { metadata_fixture(:conditionalcontent) }
    subject(:uuids_to_include) { evaluate_content_conditionals.uuids_to_include }

    context 'when the question is a checkbox' do
      let(:component) { service.find_page_by_url('best-content').components[2] }

      context 'when single expression is met' do
        let(:user_data) do
          {
            'multiple_checkboxes_1' => ''
          }
        end

        it 'returns the content component uuid' do
          expect(uuids_to_include.first).to eq(component.uuid)
        end
      end

      context 'when conditions are not met' do
        let(:user_data) do
          {
            'multiple_checkboxes_1' => ['1']
          }
        end

        it 'returns an empty array' do
          expect(uuids_to_include).to eq([])
        end
      end
    end

    context 'when the question is a radio' do
      let(:component) { service.find_page_by_url('best-content').components[0] }

      context 'when A condition is met' do
        let(:user_data) do
          {
            'multiple_radios_1' => 'Option A'
          }
        end

        it 'returns the component uuid' do
          expect(uuids_to_include.first).to eq(component.uuid)
        end
      end

      context 'when B condition is met' do
        let(:component) { service.find_page_by_url('best-content').components[1] }
        let(:user_data) do
          {
            'multiple_radios_1' => 'Option B'
          }
        end

        it 'returns the component uuid' do
          expect(uuids_to_include.first).to eq(component.uuid)
        end
      end

      context 'when none of the conditions are met' do
        let(:user_data) do
          {
            'multiple_radios_1' => 'No Option'
          }
        end

        it 'returns an empty array' do
          expect(uuids_to_include).to eq([])
        end
      end
    end

    context 'when multiple conditionals' do
      context 'when multiple expressions with "OR" rule' do
        let(:component) { service.find_page_by_url('best-content').components[0]  }

        context 'when choosing one option' do
          let(:user_data) do
            {
              'multiple_radios_1' => 'Option A'
            }
          end

          it 'returns the component uuid' do
            expect(uuids_to_include.first).to eq(component.uuid)
          end
        end

        context 'when choosing the alternative option to show same content' do
          let(:user_data) do
            {
              'multiple_radios_1' => 'Option C'
            }
          end

          it 'returns the component uuid' do
            expect(uuids_to_include.first).to eq(component.uuid)
          end
        end
      end
    end

    context 'when the question is optional' do
      context 'and the question is answered' do
        let(:component) { service.find_page_by_url('best-content').components[0] }
        let(:user_data) do
          {
            'multiple_checkboxes_1' => ['2']
          }
        end

        it 'does not remind the user to answer the question' do
          expect(uuids_to_include).to eq([])
        end
      end
    end
  end
end
