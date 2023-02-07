module MetadataPresenter
  class AnswersController < EngineController
    before_action :check_page_exists

    def create
      @previous_answers = reload_user_data.deep_dup
      @page_answers = PageAnswers.new(page, answers_params, autocomplete_items(page.components))

      upload_files if upload?

      if @page_answers.validate_answers
        save_user_data # method signature
        redirect_to_next_page
      else
        render_validation_error
      end
    end

    private

    def page
      @page ||= begin
        current_page = service.find_page_by_url(page_url)
        MetadataPresenter::Page.new(current_page.metadata) if current_page
      end
    end

    def redirect_to_next_page
      next_page = NextPage.new(
        service:,
        session:,
        user_data: reload_user_data,
        current_page_url: page_url,
        previous_answers: @previous_answers
      ).find

      if next_page.present?
        redirect_to_page next_page.url
      else
        not_found
      end
    end

    def render_validation_error
      @user_data = answers_params
      load_autocomplete_items

      render template: page.template, status: :unprocessable_entity
    end

    def answers_params
      params[:answers] ? params[:answers].permit! : {}
    end

    def page_url
      request.env['PATH_INFO']
    end

    def check_page_exists
      not_found if page.blank?
    end

    def upload_files
      user_data = load_user_data
      @page_answers.page.upload_components.each do |component|
        answer = user_data[component.id]

        @page_answers.uploaded_files.push(uploaded_file(answer, component))
      end
    end

    def uploaded_file(answer, component)
      if answer.present?
        @page_answers.answers[component.id] = answer
        MetadataPresenter::UploadedFile.new(
          file: @page_answers.send(component.id),
          component:
        )
      else
        FileUploader.new(
          session:,
          page_answers: @page_answers,
          component:,
          adapter: upload_adapter
        ).upload
      end
    end

    def upload_adapter
      super if defined?(super)
    end

    def upload?
      Array(page.components).any?(&:upload?)
    end
  end
end
