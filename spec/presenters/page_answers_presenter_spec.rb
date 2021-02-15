RSpec.describe MetadataPresenter::PageAnswersPresenter do
  subject(:presenter) do
    described_class.new(
      view: view,
      page: page,
      component: component,
      answers: answers
    )
  end
  let(:view) { MetadataPresenter::PagesController.new.view_context }
  let(:pages) { service.pages }
  let(:component) { page.components.first }

  describe '.map' do
    let(:answers) { {} }

    it 'returns instance of page answers' do
      expect(
        described_class.map(view: view, pages: pages, answers: answers).collect(&:url)
      ).to include('/name')
    end
  end

  describe '#answer' do
    context 'when component is a textarea' do
      let(:page) { service.find_page_by_url('/family-hobbies') }

      context 'when there is an answer' do
        let(:answers) do
          { component.id => "Play Star Wars\r\nWatch Mandalorian" }
        end

        it 'returns formatted value' do
          expect(presenter.answer).to eq(
            %{<span>Play Star Wars\n<br />Watch Mandalorian</span>}
          )
        end
      end

      context 'when there is no answer' do
        let(:answers) do
          {}
        end

        it 'returns empty string' do
          expect(presenter.answer).to eq('')
        end
      end
    end

    context 'when component is a date' do
      let(:page) { service.find_page_by_url('/holiday') }
      context 'when there is an answer' do
        let(:answers) do
          {
            "#{component.id}(3i)" => "01",
            "#{component.id}(2i)" => "07",
            "#{component.id}(1i)" => "2021"
          }
        end

        it 'returns formatted date' do
          expect(presenter.answer).to eq('01 July 2021')
        end
      end

      context 'when there is no answer' do
        let(:answers) { {} }

        it 'returns empty string' do
          expect(presenter.answer).to eq('')
        end
      end
    end

    context 'when component is normal formatting' do
      let(:page) { service.find_page_by_url('/name') }
      let(:answers) { { component.id => 'Mando' } }

      it 'returns value' do
        expect(presenter.answer).to eq('Mando')
      end
    end

    context 'when there is no answer' do
      let(:page) { service.find_page_by_url('/name') }
      let(:answers) { {} }

      it 'returns empty string' do
        expect(presenter.answer).to eq('')
      end
    end
  end
end
