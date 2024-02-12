module MetadataPresenter
  class ResumeController < EngineController
    include Concerns::SaveAndReturn

    helper_method :get_service_name, :get_uuid, :pages_presenters

    def return
      response = get_saved_progress(get_uuid)

      if response.status == 404
        redirect_to '/record_error' and return
      end

      if response.status == 400
        redirect_to '/record_failure' and return
      end

      if response.status == 422
        redirect_to '/already_used' and return
      end

      @saved_form = SavedForm.new.from_json(response.body.to_json)
      @resume_form = ResumeForm.new(@saved_form.secret_question)
    end

    # rubocop:disable Style/RescueStandardError
    def submit_secret_answer
      response = get_saved_progress(get_uuid)

      if response.status != 200
        if response.status == 400
          redirect_to '/record_failure' and return
        end

        redirect_to '/record_error' and return
      end

      @saved_form = SavedForm.new.from_json(response.body.to_json)
      @resume_form = ResumeForm.new(@saved_form.secret_question)
      @resume_form.secret_answer = resume_form_params[:secret_answer]
      @resume_form.recorded_answer = @saved_form.secret_answer
      @resume_form.attempts_remaining = 2 - @saved_form.attempts.to_i

      if @resume_form.valid?
        # redirect back to right place in form
        session[:user_id] = @saved_form.user_id
        session[:user_token] = @saved_form.user_token
        session[:returning_slug] = @saved_form.page_slug

        invalidate_record(@saved_form.id)

        if @saved_form.service_version == service.version_id
          redirect_to '/resume_progress' and return
        else
          redirect_to '/resume_from_start' and return
        end
      else
        if @resume_form.attempts_remaining <= 0
          begin
            increment_record_counter(@saved_form.id)
          rescue => e
            Rails.logger.info(e)
            redirect_to '/record_failure' and return
          end
          redirect_to '/record_failure' and return
        end

        increment_record_counter(@saved_form.id)

        render :return, params: { uuid: @saved_form.id }
      end
    end
    # rubocop:enable Style/RescueStandardError

    def resume_progress
      @user_data = load_user_data

      @page ||= service.checkanswers_page

      if @page
        @page_answers = PageAnswers.new(@page, @answered_pages)
      else
        not_found
      end
    end

    def answered_pages
      TraversedPages.new(service, @user_data, @page).all
    end

    def pages_presenters
      PageAnswersPresenter.map(
        view: view_context,
        pages: answered_pages,
        answers: @user_data
      )
    end

    private

    def resume_form_params
      params.require(:resume_form).permit(
        :secret_answer, :uuid
      )
    end

    def get_uuid
      if params[:uuid].present?
        return params[:uuid]
      end

      resume_form_params[:uuid].presence
    end

    def get_service_name
      service.service_name
    end
  end
end
