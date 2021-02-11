RSpec.describe MetadataPresenter::ApplicationHelper, type: :helper do
  describe '#main_h1' do
    context 'when component has a legend' do
      let(:component) do
        MetadataPresenter::Component.new(legend: 'Luke Skywalker')
      end

      it 'returns h1 wrapped in a legend' do
        expect(helper.main_h1(component)).to eq(
          %{<legend class="govuk-fieldset__legend govuk-fieldset__legend--l"><h1 class="govuk-fieldset__heading">Luke Skywalker</h1></legend>}
        )
      end
    end

    context 'when component has a label' do
      let(:component) do
        MetadataPresenter::Component.new(label: 'Luke Skywalker')
      end

      it 'returns h1 wrapped in a legend' do
        expect(helper.main_h1(component)).to eq(
          %{<h1 class="govuk-heading-xl">Luke Skywalker</h1>}
        )
      end
    end
  end

  describe '#a' do
    before do
      helper.instance_variable_set(:@user_data, user_data)
    end

    context 'when there is an answer' do
      let(:user_data) do
        { 'ewoks-communication' => 'ewokie talkies' }
      end

      it 'returns answer for a question' do
        expect(helper.a('ewoks-communication')).to eq(
          'ewokie talkies'
        )
      end
    end

    context 'when there is no answer' do
      let(:user_data) { {} }

      it 'returns answer for a question' do
        expect(helper.a('ewoks-communication')).to be_nil
      end
    end
  end

  describe '#formatted_answer' do
    before do
      helper.instance_variable_set(:@user_data, user_data)
    end

    context 'when answer has a format' do
      let(:user_data) do
        { 'what-do-gungans-put-things-in' => "Gungans put things in: \n Jar Jars" }
      end

      it 'returns answer for a question with simple format' do
        expect(helper.formatted_answer('what-do-gungans-put-things-in')).to eq(
          "<p>Gungans put things in: \n<br /> Jar Jars</p>"
        )
      end
    end

    context 'when there is no answer' do
      let(:user_data) { {} }

      it 'returns answer for a question' do
        expect(helper.formatted_answer('ewoks-communication')).to be_nil
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
