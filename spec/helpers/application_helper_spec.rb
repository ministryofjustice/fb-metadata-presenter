RSpec.describe MetadataPresenter::ApplicationHelper, type: :helper do
  describe '#main_title' do
    context 'when component has a legend' do
      let(:component) do
        MetadataPresenter::Component.new({ legend: 'Luke Skywalker' })
      end

      it 'returns h1 wrapped in a legend by default' do
        expect(helper.main_title(component:)).to eq(
          %(<h1 class="govuk-heading-xl">Luke Skywalker</h1>)
        )
      end
    end

    context 'when component has a label' do
      let(:component) do
        MetadataPresenter::Component.new({ label: 'Luke Skywalker' })
      end

      it 'returns h1 default' do
        expect(helper.main_title(component:)).to eq(
          %(<h1 class="govuk-heading-xl">Luke Skywalker</h1>)
        )
      end
    end

    context 'when tag and classes supplied' do
      let(:component) do
        MetadataPresenter::Component.new({ label: 'Mace Windu' })
      end

      it 'returns the element wrapped in the right tag with classes' do
        expect(
          helper.main_title(component:, tag: :h2, classes: 'govuk-heading-m govuk-margin-top-5')
        ).to eq(
          %(<h2 class="govuk-heading-m govuk-margin-top-5">Mace Windu</h2>)
        )
      end
    end
  end

  describe '#to_html' do
    it 'renders markdown' do
      expect(helper.to_html('# Jedi Denial - Obi-Wan Cannot be')).to eq(
        "<h1 id=\"jedi-denial---obi-wan-cannot-be\">Jedi Denial - Obi-Wan Cannot be</h1>\n"
      )
    end
  end
end
