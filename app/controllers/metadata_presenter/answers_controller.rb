module MetadataPresenter
  class AnswersController < EngineController
    before_action :check_page_exists

    def create
      @previous_answers = reload_user_data.deep_dup

      @page_answers = PageAnswers.new(page, incoming_answer, autocomplete_items(page.components))
      if params[:save_for_later].present?
        save_user_data
        # NOTE: if the user is on a file upload page, files will not be uploaded before redirection
        redirect_to save_path(page_slug: params[:page_slug]) and return
      end

      upload_files if upload?
      upload_files if multiupload?

      if @page_answers.validate_answers
        save_user_data # method signature

        # if adding another file in multi upload, redirect back to referrer
        if params[:multifile] && @page.metadata.components.any? { |e| e['_type'] == 'multiupload' }
          redirect_back(fallback_location: root_path) and return
        end

        redirect_to_next_page
      else
        if params[:multifile] && @page.metadata.components.any? { |e| e['_type'] == 'multiupload' }
          @user_data = @previous_answers
          render template: @page.template, status: :unprocessable_entity and return
        end
        render_validation_error
      end
    end

    def update_count_matching_filenames(original_filename, user_data)
      extname = File.extname(original_filename)
      basename = File.basename(original_filename, extname)
      filename_regex = /^#{Regexp.quote(basename)}(?>-\((\d)\))?#{Regexp.quote(extname)}/

      user_data.select { |_k, v| v.instance_of?(Hash) && v['original_filename'] =~ filename_regex }.count
    end

    def multiupload_files_remaining
      component = @page.components.select { |c| c.type == 'multiupload' }.first
      answers = @user_data.keys.include?(component.id) ? @user_data.find(component.id).first : []

      if uploads_remaining.zero?
        I18n.t('presenter.questions.multiupload.none')
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
    helper_method :multiupload_files_remaining

    def uploads_remaining
      component = @page.components.select { |c| c.type == 'multiupload' }.first
      max_files = component['max_files'].to_i
      answers = @user_data.keys.include?(component.id) ? @user_data[component.id] : []
      max_files - answers.count
    end
    helper_method :uploads_remaining

    def uploads_count
      component = @page.components.select { |c| c.type == 'multiupload' }.first
      answers = @user_data.keys.include?(component.id) ? @user_data[component.id] : []

      answers.count == 1 ? I18n.t('presenter.questions.multiupload.answered_count_singular') : I18n.t('presenter.questions.multiupload.answered_count_plural', num: answers.count)
    end
    helper_method :uploads_count

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

    def incoming_answer
      if multiupload?
        multiupload_answer = MultiUploadAnswer.new
        multiupload_answer.key = Array(page.components).first.id
        multiupload_answer.previous_answers = @previous_answers[Array(page.components).first.id]
        multiupload_answer.incoming_answer = answers_params
      end
      multiupload_answer || answers_params
    end

    def answers_params
      params.permit(:page_slug, :save_for_later)
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
        original_filename = answer.nil? ? @page_answers.send(component.id)['original_filename'] : answer['original_filename']

        if original_filename.present?
          @page_answers.count = update_count_matching_filenames(original_filename, user_data)
        end

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

    def multiupload?
      Array(page.components).any?(&:multiupload?)
    end
  end
end
