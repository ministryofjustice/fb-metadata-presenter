RSpec.describe MetadataPresenter::EvaluateContentConditionals do
  subject(:evaluate_content_conditionals) do
    described_class.new(
      service:,
      candidate_component: component,
      user_data:
    )
  end

  describe '#uuids_to_include' do
    let(:service_metadata) { metadata_fixture(:conditional) }
    subject(:uuids_to_include) { evaluate_content_conditionals.uuids_to_include }

    context 'when the question is a radio' do
      let(:component) { service.find_page_by_url('best-content').components[0] }

      context 'when A condition is met' do
        let(:user_data) { { 'multiple_radios_1' => 'Option A' } }

        it 'returns the component uuid' do
          expect(uuids_to_include.first).to eq(component.uuid)
        end
      end

      context 'when B condition is met' do
        let(:component) { service.find_page_by_url('best-content').components[1] }
        let(:user_data) { { 'multiple_radios_1' => 'Option B' } }

        it 'returns the component uuid' do
          expect(uuids_to_include.first).to eq(component.uuid)
        end
      end

      context 'when none of the conditions are met' do
        let(:user_data) { { 'multiple_radios_1' => 'No Option' } }

        it 'returns an empty array' do
          expect(uuids_to_include).to eq([])
        end
      end

      context 'when condition is \'is_not\'' do
        let(:component) { service.find_page_by_url('best-content').components[4] }
        let(:user_data) { { 'multiple_radios_1' => 'Option B' } }

        it 'returns the component uuid' do
          expect(uuids_to_include.first).to eq(component.uuid)
        end
      end
    end

    context 'when the question is a checkbox' do
      let(:component) { service.find_page_by_url('best-content').components[2] }

      context 'when checking that question is_not_answered' do
        let(:user_data) { { 'multiple_checkboxes_1' => '' } }

        it 'returns the content component uuid' do
          expect(uuids_to_include.first).to eq(component.uuid)
        end
      end

      context 'when conditions are not met' do
        let(:user_data) { { 'multiple_checkboxes_1' => %w[1] } }

        it 'returns an empty array' do
          expect(uuids_to_include).to eq([])
        end
      end
    end

    context 'when multiple conditionals' do
      context 'when multiple expressions with "OR" rule' do
        let(:component) { service.find_page_by_url('best-content').components[0] }

        context 'when choosing one option' do
          let(:user_data) { { 'multiple_radios_1' => 'Option A' } }

          it 'returns the component uuid' do
            expect(uuids_to_include.first).to eq(component.uuid)
          end
        end

        context 'when choosing the alternative option to show same content' do
          let(:user_data) { { 'multiple_radios_1' => 'Option C' } }

          it 'returns the component uuid' do
            expect(uuids_to_include.first).to eq(component.uuid)
          end
        end
      end
    end

    context 'when the question is optional' do
      context 'and the question is answered' do
        let(:component) { service.find_page_by_url('best-content').components[0] }
        let(:user_data) { { 'multiple_checkboxes_1' => %w[2] } }

        it 'does not remind the user to answer the question' do
          expect(uuids_to_include).to eq([])
        end
      end
    end
  end
end
