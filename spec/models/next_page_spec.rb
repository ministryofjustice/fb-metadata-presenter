RSpec.shared_context 'branching flow' do
  let(:service_metadata) do
    metadata_fixture(:branching)
  end
  let(:session) { {} }

  context 'when first page' do
    let(:current_page_url) { '/' }

    it 'returns first page' do
      expect(result).to eq(
        MetadataPresenter::Page.new({ _id: 'page.name' })
      )
    end
  end

  context 'when last page inside the branch' do
    let(:current_page_url) { 'apple-juice' }
    let(:user_data) do
      {
        'apple-juice_radios_1' => 'Yes'
      }
    end

    it 'returns to the main flow' do
      expect(result).to eq(
        MetadataPresenter::Page.new({ _id: 'page.favourite-band' })
      )
    end
  end

  context 'when radio is selected' do
    let(:current_page_url) { 'do-you-like-star-wars' }
    let(:user_data) do
      {
        'name_text_1' => 'Din Djarin',
        'do-you-like-star-wars_radios_1' => branching_answer
      }
    end

    context 'when conditional is met' do
      let(:branching_answer) { 'Only on weekends' }

      it 'returns next page in the branch' do
        expect(result).to eq(
          MetadataPresenter::Page.new({ _id: 'page.star-wars-knowledge' })
        )
      end
    end

    context 'when conditional is not met' do
      let(:branching_answer) { 'Hell no!' }

      it 'returns next page in main flow sequence' do
        expect(result).to eq(
          MetadataPresenter::Page.new({ _id: 'page.favourite-fruit' })
        )
      end
    end
  end
end

RSpec.describe MetadataPresenter::NextPage do
  subject(:next_page) do
    described_class.new(
      service:,
      session:,
      user_data:,
      current_page_url:,
      previous_answers:
    )
  end
  let(:user_data) { {} }
  let(:previous_answers) { nil }

  describe '#find' do
    subject(:result) do
      next_page.find
    end

    include_context 'branching flow'

    context 'when user wants to change their answer' do
      let(:session) do
        { return_to_check_your_answer: true }
      end

      context 'when there is no conditions depending on the page' do
        let(:current_page_url) { 'name' }

        it 'returns check your answer page' do
          expect(result).to eq(
            MetadataPresenter::Page.new({ _id: 'page.check-answers' })
          )
        end

        it 'set the session as nil' do
          result
          expect(session).to eq({ return_to_check_your_answer: nil })
        end
      end

      context 'when there is conditions depending on the answered page' do
        context 'when the answer is changed' do
          let(:previous_answers) do
            {
              'favourite-fruit_radios_1' => 'Apples'
            }
          end
          let(:user_data) do
            {
              'favourite-fruit_radios_1' => 'Oranges'
            }
          end
          let(:session) do
            {
              return_to_check_your_answer: true
            }
          end
          let(:current_page_url) { 'favourite-fruit' }

          it 'returns the next evaluated page (now branching has changed)' do
            expect(result).to eq(
              MetadataPresenter::Page.new({ _id: 'page.orange-juice' })
            )
          end
        end

        context 'when the answer is the same' do
          let(:previous_answers) do
            {
              'favourite-fruit_radios_1' => 'Apples'
            }
          end
          let(:user_data) do
            {
              'favourite-fruit_radios_1' => 'Apples'
            }
          end
          let(:session) do
            {
              return_to_check_your_answer: true
            }
          end
          let(:current_page_url) { 'favourite-fruit' }

          it 'return to check your answers page' do
            expect(result).to eq(
              MetadataPresenter::Page.new({ _id: 'page.check-answers' })
            )
          end
        end
      end
    end

    context 'when there is no next page' do
      let(:service_metadata) do
        metadata_fixture(:non_finished_service)
      end
      let(:session) { {} }
      let(:current_page_url) { '/parent-name' }

      it 'returns nil' do
        expect(result).to be(nil)
      end
    end
  end
end
