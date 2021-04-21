RSpec.describe MetadataPresenter::NextPage do
  subject(:next_page) { described_class.new(service) }

  describe '#find' do
    subject(:result) do
      next_page.find(
        session: session,
        current_page_url: current_page_url
      )
    end

    context 'when user should return to check your answer' do
      let(:session) { { return_to_check_you_answer: true } }
      let(:current_page_url) { '' }

      it 'returns check your answer page' do
        expect(result).to eq(
          MetadataPresenter::Page.new(_id: 'page.check-answers')
        )
      end

      it 'set the session as nil' do
        result
        expect(session).to eq({ return_to_check_you_answer: nil })
      end
    end

    context 'when there is a next page' do
      let(:session) { { return_to_check_you_answer: nil } }
      let(:current_page_url) { '/name' }

      it 'returns next page in sequence' do
        expect(result).to eq(
          MetadataPresenter::Page.new(_id: 'page.email-address')
        )
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
