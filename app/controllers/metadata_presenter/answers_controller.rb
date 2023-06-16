module MetadataPresenter
  class AnswersController < EngineController
    before_action :check_page_exists

    def create
      # byebug
      @previous_answers = reload_user_data.deep_dup
      # byebug
      if(multiupload?)
        multiupload_answer = MultiUploadAnswer.new
        multiupload_answer.key = Array(page.components).first.id
        multiupload_answer.previous_answers = @previous_answers[Array(page.components).first.id]
        multiupload_answer.incoming_answer = answers_params
      end
      x = multiupload_answer || answers_params
      # byebug
      @page_answers = PageAnswers.new(page, x, autocomplete_items(page.components))
      # byebug
      if params[:save_for_later].present?
        save_user_data
        # NOTE: if the user is on a file upload page, files will not be uploaded before redirection
        redirect_to save_path(page_slug: params[:page_slug]) and return
      end
      # byebug
      upload_files if upload?
      upload_files if multiupload?
      # byebug
      if @page_answers.validate_answers
        # byebug
        save_user_data # method signature
        # byebug
        # if adding another file in multi upload, redirect back to referrer
        if(@page.metadata.present? && @page.metadata.components.present?)
          if(@page.metadata.components.any?{ |e| e['_type'] == 'multiupload' })
          # byebug
            redirect_back(fallback_location: root_path) and return
          end
        end
        redirect_to_next_page
      else
        # byebug
        render_validation_error
      end
    end

    def update_count_matching_filenames(original_filename, user_data)
      extname = File.extname(original_filename)
      basename = File.basename(original_filename, extname)
      filename_regex = /^#{Regexp.quote(basename)}(?>-\((\d)\))?#{Regexp.quote(extname)}/

      user_data.select { |_k, v| v.instance_of?(Hash) && v['original_filename'] =~ filename_regex }.count
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
        # byebug
        original_filename = answer.nil? ? @page_answers.send(component.id)['original_filename'] : answer['original_filename']

        if original_filename.present?
          @page_answers.count = update_count_matching_filenames(original_filename, user_data)
        end

        @page_answers.uploaded_files.push(uploaded_file(answer, component))
      end
    end

    def batch_upload_files
      user_data = load_user_data
      @page_answers.page.multiupload_components.each do |component|
        answer = user_data[component.id]
        # byebug
        # TODO: check each filename for duplicates
        # if answer.nil?
        @page_answers.uploaded_files.push(uploaded_file(answer, component))
        # else
          # answer should be an array of files, not replaced
          # @page_answers.uploaded_files.push(uploaded_file(, component))
          
        # end
      end
    end

    def uploaded_file(answer, component)
      # if component.multiupload?
      #   if answer.present?
      #     @page_answers.answers[component.id] = answer
      #   else
      #     FileUploader.new(
      #       session:,
      #       page_answers: @page_answers,
      #       component:,
      #       adapter: upload_adapter
      #     ).upload
      #   end
      # else
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
      # end
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
