RSpec.describe MetadataPresenter::EvaluateContentConditionals do
  subject(:evaluate_content_conditionals) do
    described_class.new(
      service:,
      user_data:
    )
  end

  describe '#evaluate_content_components' do
    let(:service_metadata) { metadata_fixture(:conditional_content) }
    subject(:conditional_content) { evaluate_content_conditionals.evaluate_content_components(page) }
    let(:page) { service.find_page_by_url('content') }

    context 'when content should never be displayed' do
      let(:user_data) { { 'multiple_checkboxes_1' => %w[1 2], 'multiple_radios_1' => 'Option B' } }
      let(:never_component) { '1ed7161c-b712-429c-b647-edd39f71b39f' }

      it 'is not returned' do
        expect(conditional_content).to_not include(never_component)
      end
    end

    context 'when content should always be displayed' do
      let(:user_data) { {} }
      let(:expected_component) { '6a3b4104-1d4c-4534-87d8-b81f5c764d43' }

      it 'is returned' do
        expect(conditional_content).to include(expected_component)
      end
    end

    context 'when condition is a checkbox' do
      context 'when operator is contains' do
        let(:expected_component) { '2e8d0ad4-5640-4cd5-815c-4f4116a685d5' }

        context 'when checkbox contains the right answer' do
          let(:user_data) { { 'multiple_checkboxes_1' => %w[1] } }
          it 'conditional content uuid is returned' do
            expect(conditional_content).to include(expected_component)
          end
        end

        context 'when checkbox does not contain the right answer' do
          let(:user_data) { { 'multiple_checkboxes_1' => %w[2] } }
          it 'conditional content uuid is not returned' do
            expect(conditional_content).to_not include(expected_component)
          end
        end
      end

      context 'when the operator is does_not_contains' do
        let(:expected_component) { '701f93e3-1d78-4a1f-9495-07e32b6e26fe' }
        context 'when checkbox has a right answer' do
          let(:user_data) { { 'multiple_checkboxes_1' => %w[2] } }
          it 'conditional content uuid is returned' do
            expect(conditional_content).to include(expected_component)
          end
        end

        context 'when checkbox has a wrong answer' do
          let(:user_data) { { 'multiple_checkboxes_1' => %w[1] } }
          it 'conditional content uuid is returned' do
            expect(conditional_content).to_not include(expected_component)
          end
        end
      end
    end

    context 'when question is optional' do
      context 'when operator is not_answered' do
        let(:expected_component) { '37a83516-20c3-4208-ae5f-752038113742' }
        context 'when checkbox has a right answer' do
          let(:user_data) { { 'multiple_checkboxes_1' => [] } }
          it 'conditional content uuid is returned' do
            expect(conditional_content).to include(expected_component)
          end
        end

        context 'when checkbox has a wrong answer' do
          let(:user_data) { { 'multiple_checkboxes_1' => %w[1] } }
          it 'conditional content uuid is returned' do
            expect(conditional_content).to_not include(expected_component)
          end
        end
      end

      context 'when the operator is answered' do
        let(:expected_component) { '71bfc176-613d-42ec-8d53-63e50b696ec6' }

        context 'when checkbox has a right answer' do
          let(:user_data) { { 'multiple_checkboxes_1' => %w[2] } }
          it 'conditional content uuid is returned' do
            expect(conditional_content).to include(expected_component)
          end
        end

        context 'when checkbox has a wrong answer' do
          let(:user_data) { { 'multiple_checkboxes_1' => [] } }
          it 'conditional content uuid is returned' do
            expect(conditional_content).to_not include(expected_component)
          end
        end
      end
    end

    context 'when operator is equal to for a radio' do
      let(:expected_component) { '6a3b4104-1d4c-4534-87d8-b81f5c764d43' }

      context 'when then condition is met' do
        let(:user_data) { { 'multiple_radios_1' => 'Option A' } }
        it 'the expected conditional component is returned' do
          expect(conditional_content).to include(expected_component)
        end
      end

      context 'when the condition is not met' do
        let(:user_data) { { 'multiple_radios_1' => 'Option B' } }
        it 'the expected conditional component is returned' do
          expect(conditional_content).to include(expected_component)
        end
      end
    end

    context 'when operator is is_not for a radio' do
      let(:not_a_uuid) { '75fd4dd0-2be1-44d0-9153-d7ec5ceb2a55' }
      let(:no_no_option_uuid) { '61139d00-53eb-4ff3-9227-6ecd0b80aac4' }

      context 'when multiple conditions with different results are met' do
        let(:user_data) { { 'multiple_radios_1' => 'Option B' } }
        it 'all corresponding components are being displayed' do
          expect(conditional_content).to include(not_a_uuid, no_no_option_uuid)
        end
      end

      context 'when multiple conditions are not met' do
        let(:user_data) { { 'multiple_radios_1' => 'No Option' } }

        it 'one of them is included' do
          expect(conditional_content).to include(not_a_uuid)
        end

        it 'one of them is excluded' do
          expect(conditional_content).to_not include(no_no_option_uuid)
        end
      end
    end

    context 'for multiple conditions using the or rule' do
      let(:one_or_a_or_c_uuid) { '4d4d7ace-9ce2-4415-9edb-abcac75ed17b' }

      context 'when checkbox is 1' do
        let(:user_data) { { 'multiple_checkboxes_1' => %w[1] } }
        it 'detects that 1 or A or C have been selected' do
          expect(conditional_content).to include(one_or_a_or_c_uuid)
        end
      end

      context 'when radio is a' do
        let(:user_data) { { 'multiple_radios_1' => 'Option A' } }
        it 'detects that 1 or A or C have been selected' do
          expect(conditional_content).to include(one_or_a_or_c_uuid)
        end
      end

      context 'when radio is c' do
        let(:user_data) { { 'multiple_radios_1' => 'Option C' } }
        it 'detects that 1 or A or C have been selected' do
          expect(conditional_content).to include(one_or_a_or_c_uuid)
        end
      end
    end

    context 'for multiple conditions combined with the and rule' do
      let(:two_and_b) { '5ccc3681-4aa5-447a-8763-6fcdd257bfcc' }
      context 'when all conditions are met' do
        let(:user_data) { { 'multiple_checkboxes_1' => %w[2], 'multiple_radios_1' => 'Option B' } }
        it 'returns successfully the content' do
          expect(conditional_content).to include(two_and_b)
        end
      end

      context 'when only one condition is met' do
        let(:user_data) { { 'multiple_radios_1' => 'Option B' } }

        it 'does not return the content' do
          expect(conditional_content).to_not include(two_and_b)
        end
      end
    end

    context 'for multiple conditions with or and and rule combined' do
      let(:rare_content) { 'b23d885d-5326-49f2-b4f4-5ac5d53a03da' }

      context 'when conditions are met' do
        context 'in case 1' do
          let(:user_data) { { 'multiple_checkboxes_1' => %w[1], 'multiple_radios_1' => 'Option A' } }
          it 'expected conditional content is displayed' do
            expect(conditional_content).to include(rare_content)
          end
        end

        context 'in case 2' do
          let(:user_data) { { 'multiple_checkboxes_1' => [], 'multiple_radios_1' => 'No Option' } }
          it 'expected conditional content is displayed' do
            expect(conditional_content).to include(rare_content)
          end
        end
      end
      context 'when conditions are not met' do
        context 'in some case' do
          let(:user_data) { { 'multiple_checkboxes_1' => %w[2], 'multiple_radios_1' => 'Option B' } }
          it 'expected conditional content is not displayed' do
            expect(conditional_content).to_not include(rare_content)
          end
        end

        context 'in another case' do
          let(:user_data) { { 'multiple_checkboxes_1' => [], 'multiple_radios_1' => 'Option C' } }
          it 'expected conditional content is not displayed' do
            expect(conditional_content).to_not include(rare_content)
          end
        end
      end
    end
  end
end
