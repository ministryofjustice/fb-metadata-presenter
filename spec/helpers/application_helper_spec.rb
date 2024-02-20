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

  describe '#timeout_fallback' do
    let(:time) { Time.zone.now }

    it 'returns the time in the right format' do
      expect(helper.timeout_fallback(time)).to eq(time.strftime('%l:%M %p'))
    end

    it 'returns the string if the time is a string' do
      expect(helper.timeout_fallback(time.to_s)).to eq(time.to_s)
    end
  end

  describe '#default_item_title' do
    context 'when component is a not a checkbox nor a radio' do
      let(:component_type) { 'text' }

      it 'returns nil' do
        expect(default_item_title(component_type)).to be_nil
      end
    end

    context 'when component is a checkbox' do
      let(:component_type) { 'checkboxes' }

      it 'returns Option' do
        expect(default_item_title(component_type)).to eq('Option')
      end
    end

    context 'when component is a radio' do
      let(:component_type) { 'radios' }

      it 'returns Option' do
        expect(default_item_title(component_type)).to eq('Option')
      end
    end
  end

  describe '#files_to_render' do
    let(:page) { OpenStruct.new(components: [component]) }
    let(:component) do
      OpenStruct.new({ id: 'upload_multiupload_1', type: 'multiupload', validation: { 'max_files' => '2' } })
    end

    let(:page_answers) { double(MetadataPresenter::PageAnswers) }
    let(:uploaded_files) do
      [
        {
          'original_filename' => 'computer_says_no.gif',
          'content_type' => 'image/gif',
          'tempfile' => 'filepath'
        },
        {
          'original_filename' => 'diagram.png',
          'content_type' => 'image/png',
          'tempfile' => 'another_filepath'
        }
      ]
    end
    let(:upload_component) { { 'upload_multiupload_1' => uploaded_files } }

    before do
      allow(page_answers).to receive(:uploaded_files).and_return([])
      allow(page_answers).to receive(:upload_multiupload_1).and_return(upload_component)
      controller.instance_variable_set(:@page, page)
      controller.instance_variable_set(:@page_answers, page_answers)
    end

    it 'list the files to render' do
      expect(helper.files_to_render).to eq(uploaded_files)
    end
  end

  describe 'page body content' do
    let(:page) { OpenStruct.new(body: body) }
    let(:body) { '' }

    before do
      controller.instance_variable_set(:@page, page)
    end

    it 'returns the content' do
      expect(helper.page_body_content).to eq(body)
    end

    context 'using old default' do
      let(:body) { 'Body section' }

      it 'gives blank response' do
        expect(helper.page_body_content).to eq('')
      end
    end

    context 'body content has been customised' do
      let(:body) { 'I am a new Body section' }

      it 'gives the content' do
        expect(helper.page_body_content).to eq(body)
      end
    end
  end
end
