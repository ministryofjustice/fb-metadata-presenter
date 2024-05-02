describe MetadataPresenter::Summary::AnswersPresenter do
  subject { described_class.new(page_answers) }

  let(:page_answers) { [answer_1, answer_2] }

  let(:page) { double(type: page_type) }
  let(:page_type) { 'page.multiplequestions' }

  let(:answer_1) { double(page:, answer: 'foobar') }
  let(:answer_2) { double(page:, answer: '') }

  describe '#to_partial_path' do
    it 'returns the correct partial path' do
      expect(subject.to_partial_path).to eq('metadata_presenter/resume/answers_presenter')
    end
  end

  describe '#page' do
    it 'uses the first answer to retrieve the page' do
      expect(subject.page).to eq(page)
    end
  end

  describe '#answers' do
    it 'returns a collection of answered (non-blank) answers' do
      expect(subject.answers).to eq([answer_1])
    end
  end

  describe '#multi_questions_page?' do
    context 'for a single page type' do
      let(:page_type) { 'page.singlequestion' }

      it { expect(subject.multi_questions_page?).to eq(false) }
    end

    context 'for a multiquestions page type' do
      it { expect(subject.multi_questions_page?).to eq(true) }
    end
  end
end
