module MetadataPresenter
  class AnswersController < EngineController
    before_action :check_page_exists

    def create
      @previous_answers = reload_user_data.deep_dup

      @page_answers = PageAnswers.new(page, incoming_answer, autocomplete_items(page.components))

      if params[:save_for_later].present?
        save_user_data unless upload? || multiupload?

        redirect_to save_path(page_slug: params[:page_slug]) and return
      end

      upload_files if upload?
      upload_multiupload_new_files if multiupload? && answers_params.present?

      if @page_answers.validate_answers
        save_user_data # method signature

        # if adding another file in multi upload, redirect back to referrer
        if about_to_render_multiupload?
          redirect_back(fallback_location: root_path) and return
        end

        redirect_to_next_page
      else
        # can't render error in the same way for the multiupload component
        if about_to_render_multiupload?
          @user_data = @previous_answers

          render template: @page.template, status: :unprocessable_entity and return
        end
        render_validation_error
      end
    end

    def about_to_render_multiupload?
      answers_params.present? && multiupload?
    end

    def update_count_matching_filenames(original_filename, user_data)
      extname = File.extname(original_filename)
      basename = File.basename(original_filename, extname)
      filename_regex = /^#{Regexp.quote(basename)}(?>-\((\d)\))?#{Regexp.quote(extname)}/

      user_data.select { |_k, v|
        if v.is_a?(Array)
          v.any? { |e| e['original_filename'] =~ filename_regex }
        else
          v['original_filename'] =~ filename_regex
        end
      }.count
    end

    def upload_multiupload_new_files
      user_data = load_user_data
      @page_answers.page.multiupload_components.each do |component|
        previous_answers = user_data[component.id]
        incoming_filename = @page_answers.send(component.id)[component.id].last['original_filename']

        if editor_preview?
          @page_answers.uploaded_files.push(multiuploaded_file(previous_answers, component))
        else

          if incoming_filename.present?
            # determine if duplicate filename from any other user answer
            @page_answers.count = update_count_matching_filenames(incoming_filename, user_data)
          end

          if previous_answers.present? && previous_answers.any? { |answer| answer['original_filename'] == incoming_answer.incoming_answer.values.first.original_filename }
            @page_answers.count = nil # ensure we don't also try to suffix this filename as we will reject it anyway
            file = MetadataPresenter::UploadedFile.new(
              file: @page_answers.send(component.id)[component.id].last,
              component:
            )

            file.errors.add('invalid.multiupload')
            @page_answers.uploaded_files.push(file)
          else
            @page_answers.uploaded_files.push(multiuploaded_file(previous_answers, component))
          end
        end
      end
    end

    def show_save_and_return
      page.upload_components.none?
    end
    helper_method :show_save_and_return

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

    def multiuploaded_file(answer, component)
      if answer.present?
        if @page_answers.answers.is_a?(MetadataPresenter::MultiUploadAnswer)
          if @page_answers.answers.incoming_answer.present?
            FileUploader.new(
              session:,
              page_answers: @page_answers,
              component:,
              adapter: upload_adapter
            ).upload
          else
            MetadataPresenter::UploadedFile.new(
              file: @page_answers.answers.previous_answers.last,
              component:
            )
          end
        else
          FileUploader.new(
            session:,
            page_answers: @page_answers,
            component:,
            adapter: upload_adapter
          ).upload
        end
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
