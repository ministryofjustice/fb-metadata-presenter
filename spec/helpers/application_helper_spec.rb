RSpec.describe MetadataPresenter::ApplicationHelper, type: :helper do
  describe '#main_h1' do
    context 'when component has a legend' do
      let(:component) do
        MetadataPresenter::Component.new(legend: 'Luke Skywalker')
      end

      it 'returns h1 wrapped in a legend' do
        expect(helper.main_h1(component)).to eq(
          %{<legend class="govuk-fieldset__legend govuk-fieldset__legend--l"><h1 class="govuk-heading-xl">Luke Skywalker</h1></legend>}
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

  describe '#to_markdown' do
    it 'renders markdown' do
      expect(helper.m('# Jedi Denial - Obi-Wan Cannot be')).to eq(
        "<h1 id=\"jedi-denial---obi-wan-cannot-be\">Jedi Denial - Obi-Wan Cannot be</h1>\n"
      )
    end
  end
end
