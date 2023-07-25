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

  describe '#page_upload_component' do
    let(:page) { OpenStruct.new(components:) }
    let(:components) do
      [
        OpenStruct.new({ id: 'cool-files', type: 'multiupload', validation: { 'max_files' => '2' } }),
        OpenStruct.new({ id: 'more-cool-files', type: 'multiupload', validation: { 'max_files' => '3' } })
      ]
    end

    before do
      @page = page
    end

    it 'returns only the first multiuppload component, as there should only ever be one' do
      expect(helper.page_multiupload_component.id).to eq('cool-files')
    end
  end

  describe '#uploads_remaining' do
    let(:page) { OpenStruct.new(components: [component]) }
    let(:component) do
      OpenStruct.new({ id: 'cool-files', type: 'multiupload', validation: { 'max_files' => '2' } })
    end
    let(:user_data) do
      {
        'cool-files' => [{ 'original_filename' => 'i-am-a-file.exif' }]
      }
    end

    before do
      @page = page
      @user_data = user_data
    end

    it 'gives the uploads remaining for the given component and user data' do
      expect(helper.uploads_remaining).to eq(1)
    end

    it 'returns 0 if we are in the process of uploading' do
      @user_data = {
        'cool-files' => ActionDispatch::Http::UploadedFile.new(tempfile: Rails.root.join('spec', 'fixtures', 'thats-not-a-knife.txt'))
      }

      expect(helper.uploads_remaining).to eq(0)
    end
  end

  describe '#uploads_count' do
    let(:page) { OpenStruct.new(components: [component]) }
    let(:component) do
      OpenStruct.new({ id: 'cool-files', type: 'multiupload', validation: { 'max_files' => '2' } })
    end
    let(:user_data) do
      {
        'cool-files' => [{ 'original_filename' => 'i-am-a-file.exif' }]
      }
    end

    before do
      @page = page
      @user_data = user_data
    end

    it 'gives the uploads count in singular' do
      expect(helper.uploads_count).to eq(I18n.t('presenter.questions.multiupload.answered_count_singular'))
    end

    it 'gives the uploads count pluralised' do
      @user_data = {
        'cool-files' => [{ 'original_filename' => 'i-am-a-file.exif' }, { 'original_filename' => 'i-am-also-a-file.exif' }]
      }
      expect(helper.uploads_count).to eq(I18n.t('presenter.questions.multiupload.answered_count_plural', num: 2))
    end

    it 'returns 0 if we are in the process of uploading' do
      @user_data = {
        'cool-files' => ActionDispatch::Http::UploadedFile.new(tempfile: Rails.root.join('spec', 'fixtures', 'thats-not-a-knife.txt'))
      }

      expect(helper.uploads_count).to eq(0)
    end
  end

  describe 'multiupload_files_remaining' do
    context 'no uploads remain' do
      let(:page) { OpenStruct.new(components: [component]) }
      let(:component) do
        OpenStruct.new({ id: 'cool-files', type: 'multiupload', validation: { 'max_files' => '1' } })
      end
      let(:user_data) do
        {
          'cool-files' => [{ 'original_filename' => 'i-am-a-file.exif' }]
        }
      end

      before do
        @page = page
        @user_data = user_data
      end

      it 'returns the right page text' do
        expect(helper.multiupload_files_remaining).to eq(I18n.t('presenter.questions.multiupload.none'))
      end
    end

    context 'singular upload remains' do
      let(:page) { OpenStruct.new(components: [component]) }
      let(:component) do
        OpenStruct.new({ id: 'cool-files', type: 'multiupload', validation: { 'max_files' => '2' } })
      end
      let(:user_data) do
        {
          'cool-files' => [{ 'original_filename' => 'i-am-a-file.exif' }]
        }
      end

      before do
        @page = page
        @user_data = user_data
      end

      it 'returns a singular answer' do
        expect(helper.multiupload_files_remaining).to eq(I18n.t('presenter.questions.multiupload.answered_singular'))
      end

      it 'returns the right answer if no uploads present' do
        @user_data = {}
        component = OpenStruct.new({ id: 'cool-files', type: 'multiupload', validation: { 'max_files' => '1' } })
        @page = OpenStruct.new(components: [component])

        expect(helper.multiupload_files_remaining).to eq(I18n.t('presenter.questions.multiupload.single_upload'))
      end
    end

    context 'multiple uploads remain' do
      let(:page) { OpenStruct.new(components: [component]) }
      let(:component) do
        OpenStruct.new({ id: 'cool-files', type: 'multiupload', validation: { 'max_files' => '3' } })
      end
      let(:user_data) do
        {
          'cool-files' => [{ 'original_filename' => 'i-am-a-file.exif' }]
        }
      end

      before do
        @page = page
        @user_data = user_data
      end

      it 'returns a singular answer' do
        expect(helper.multiupload_files_remaining).to eq(I18n.t('presenter.questions.multiupload.answered_plural', num: 2))
      end

      it 'returns the right answer if no uploads present' do
        @user_data = {}
        component = OpenStruct.new({ id: 'cool-files', type: 'multiupload', validation: { 'max_files' => '3' } })
        @page = OpenStruct.new(components: [component])

        expect(helper.multiupload_files_remaining).to eq(I18n.t('presenter.questions.multiupload.plural', num: 3))
      end
    end
  end
end
