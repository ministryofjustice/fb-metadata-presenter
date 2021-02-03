RSpec.describe MetadataPresenter::ApplicationHelper, type: :helper do
  describe '#a' do
    context 'when there is an answer' do
      before do
        helper.instance_variable_set(
          :@user_data,
          { 'ewoks-communication' =>'ewokie talkies' }
        )
      end

      it 'returns answer for a question' do
        expect(helper.a('ewoks-communication')).to eq(
          'ewokie talkies'
        )
      end
    end

    context 'when there is no answer' do
      it 'returns answer for a question' do
        expect(helper.a('ewoks-communication')).to be_nil
      end
    end
  end

  describe '#to_markdown' do
    it 'renders markdown' do
      expect(helper.m('# Jedi Denial - Obi-Wan Cannot be')).to eq(
        "<h1 id=\"jedi-denial---obi-wan-cannot-be\">Jedi Denial - Obi-Wan Cannot be</h1>\n"
      )
    end
  end
end
