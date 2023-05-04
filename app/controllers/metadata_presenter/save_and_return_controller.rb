module MetadataPresenter
  class SaveAndReturnController < EngineController
    # before_action :check_feature_flag
    helper_method :secret_questions, :page_slug, :confirmed_email, :get_service_name, :get_uuid, :label_text

    def show
      @saved_form = SavedForm.new
    end

    def page_slug
      if session['returning_slug'].present?
        return session['returning_slug']
      end
      if session['saved_form'].present?
        return session['saved_form']['page_slug']
      end
      if params['saved_form'].present?
        return params['saved_form']['page_slug']
      end

      params[:page_slug]
    end

    def confirmed_email
      email = session['saved_form']['email']
      session[:saved_form] = nil

      email
    end

    def create
      @saved_form = SavedForm.new
      @saved_form.populate_param_values(saved_form_params)
      @saved_form.secret_question = text_for(params['saved_form']['secret_question'])
      @saved_form.populate_service_values(service)
      @saved_form.populate_session_values(session)
      if @saved_form.valid?
        # put in session until we have confirmed email address
        session[:saved_form] = @saved_form
        redirect_to '/save/email_confirmation'
      else
        render :show, params: { page_slug: params[:page_slug], status: :unprocessable_entity }
      end
    end

    def email_confirmation
      @saved_form = session[:saved_form]
      @email_confirmation = EmailConfirmation.new
    end

    def confirm_email
      @email_confirmation = EmailConfirmation.new
      @email_confirmation.assign_attributes(confirmation_params[:email_confirmation], session['saved_form']['email'])

      if @email_confirmation.valid?
        response = save_form_progress
        if response.status == 500
          internal_server_error and return
        end

        payload = response.body.merge(email: @email_confirmation.email_confirmation).deep_symbolize_keys
        create_save_and_return_submission(payload)

        redirect_to '/save/progress_saved'
      else
        render :email_confirmation, status: :unprocessable_entity
      end
    end

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

    def get_uuid
      if params[:uuid].present?
        return params[:uuid]
      end

      params[:resume_form][:uuid].presence
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
      @resume_form.secret_answer = resume_form_params[:resume_form][:secret_answer]
      @resume_form.recorded_answer = @saved_form.secret_answer
      @resume_form.attempts_remaining = 3 - @saved_form.attempts.to_i

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

      @page ||= service.find_page_by_url('check-answers')

      if @page
        @page_answers = PageAnswers.new(@page, @answered_pages)

        render template: 'metadata_presenter/save_and_return/resume_progress'
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
    helper_method :pages_presenters

    def secret_questions
      [
        OpenStruct.new(id: 1, name: I18n.t('presenter.save_and_return.secret_questions.one')),
        OpenStruct.new(id: 2, name: I18n.t('presenter.save_and_return.secret_questions.two')),
        OpenStruct.new(id: 3, name: I18n.t('presenter.save_and_return.secret_questions.three'))
      ]
    end

    def text_for(question)
      return nil if question.blank?

      secret_questions.select { |s| s.id.to_s == question.to_s }.first.name
    end

    def saved_form_params
      params.permit(
        :email,
        :secret_answer,
        { saved_form: %i[page_slug secret_question] },
        :authenticity_token,
        :page_slug
      )
    end

    def confirmation_params
      params.permit(
        :email_confirmation,
        :authenticity_token
      )
    end

    def resume_form_params
      params.permit(
        { resume_form: %i[secret_answer uuid] },
        :authenticity_token
      )
    end

    def get_service_name
      service.service_name
    end

    def label_text(text)
      "<h2 class='govuk-heading-m'>#{text}</h2>"
    end

    private

    def check_feature_flag
      redirect_to '/' and return if ENV['SAVE_AND_RETURN'] != 'enabled'
    end
  end
end
