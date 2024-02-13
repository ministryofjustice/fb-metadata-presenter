require 'govspeak'

module MetadataPresenter
  module ApplicationHelper
    def main_title(component:, tag: :h1, classes: 'govuk-heading-xl')
      content_tag(tag, class: classes) do
        component.humanised_title
      end
    end

    # Renders html given markdown.
    #
    # @example
    #   <%=to_html '# Some markdown' %>
    #
    def to_html(text)
      Govspeak::Document.new(text).to_html.html_safe
    end

    def default_text(property)
      MetadataPresenter::DefaultText[property]
    end

    def default_title(component_type)
      MetadataPresenter::DefaultMetadata["component.#{component_type}"]&.[]('label') ||
        MetadataPresenter::DefaultMetadata["component.#{component_type}"]&.[]('legend')
    end

    def default_item_title(component_type)
      return unless %w[checkboxes radios].include?(component_type)

      MetadataPresenter::DefaultMetadata["component.#{component_type}"]['items']&.first&.[]('label')
    end

    def default_page_title(type)
      MetadataPresenter::DefaultMetadata[type.to_s]&.[]('heading')
    end

    def timeout_fallback(time)
      time.strftime('%l:%M %p')
    rescue NoMethodError
      time
    end

    def multiupload_files_remaining
      component = page_multiupload_component
      answers = @user_data.keys.include?(component.id) ? @user_data.find(component.id).first : []
      max_files = component.validation['max_files'].to_i

      if uploads_remaining.zero?
        I18n.t('presenter.questions.multiupload.none')
      elsif max_files == 1
        I18n.t('presenter.questions.multiupload.single_upload')
      elsif uploads_remaining == 1
        if answers.present?
          I18n.t('presenter.questions.multiupload.answered_singular')
        else
          I18n.t('presenter.questions.multiupload.singular')
        end
      elsif answers.present?
        I18n.t('presenter.questions.multiupload.answered_plural', num: uploads_remaining)
      else
        I18n.t('presenter.questions.multiupload.plural', num: uploads_remaining)
      end
    end

    def uploads_remaining
      component = page_multiupload_component
      max_files = component.validation['max_files'].to_i
      answers = @user_data.keys.include?(component.id) ? @user_data[component.id] : []
      return 0 if answers.is_a?(ActionDispatch::Http::UploadedFile)

      max_files - answers.count
    end

    def uploads_count
      component = page_multiupload_component
      answers = @user_data.keys.include?(component.id) ? @user_data[component.id] : []

      return 0 if answers.is_a?(ActionDispatch::Http::UploadedFile)

      answers.count == 1 ? I18n.t('presenter.questions.multiupload.answered_count_singular') : I18n.t('presenter.questions.multiupload.answered_count_plural', num: answers.count)
    end

    def files_to_render
      component = page_multiupload_component

      error_file = @page_answers.uploaded_files.select { |file| file.errors.any? }.first

      if error_file.present?
        @page_answers.send(component.id)[component.id].compact.reject { |file| file[error_file.file['original_filename'] == 'original_filename'] }
      else
        @page_answers.send(component.id)[component.id].compact
      end
    end

    def page_multiupload_component
      @page.components.select { |c| c.type == 'multiupload' }.first
    end

    def no_uploaded_files?
      component = page_multiupload_component
      return true if @user_data.nil?

      answers = @user_data.keys.include?(component.id) ? @user_data[component.id] : []
      return true if answers.count == 0

      true
    end
  end
end
