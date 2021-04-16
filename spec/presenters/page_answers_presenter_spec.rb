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
    let(:page_answers) do
      described_class.map(view: view, pages: pages, answers: answers)
    end

    it 'returns a collection of page answers presenters' do
      expect(page_answers.flatten).to all(be_a(MetadataPresenter::PageAnswersPresenter))
    end

    it 'groups page answer presenters by page' do
      page_answers.each do |page|
        expect(page.map(&:page).collect(&:id).uniq.length).to be 1
      end
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
            %(<span>Play Star Wars\n<br />Watch Mandalorian</span>)
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
            "#{component.id}(3i)" => '01',
            "#{component.id}(2i)" => '07',
            "#{component.id}(1i)" => '2021'
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

    context 'when component is a checkbox' do
      let(:page) { service.find_page_by_url('/burgers') }
      context 'when there are two boxes checked' do
        let(:answers) do
          { component.id => ['Chicken, cheese, tomato', 'Mozzarella, cheddar, feta'] }
        end

        it 'returns formatted answer' do
          expect(presenter.answer).to eq('Chicken, cheese, tomato<br>Mozzarella, cheddar, feta')
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

  describe '#display_heading?' do
    let(:answers) { {} }

    context 'when multiple question page' do
      let(:page) do
        service.find_page_by_url('/star-wars-knowledge')
      end

      context 'when first answer' do
        let(:index) { 0 }

        it 'returns true' do
          expect(subject.display_heading?(index)).to be_truthy
        end
      end

      context 'when not first answer' do
        let(:index) { 1 }

        it 'returns false' do
          expect(subject.display_heading?(index)).to be_falsey
        end
      end
    end

    context 'when any other page' do
      let(:page) do
        service.find_page_by_url('/burgers')
      end
      let(:index) { 0 }

      it 'returns false' do
        expect(subject.display_heading?(index)).to be_falsey
      end
    end
  end
end
