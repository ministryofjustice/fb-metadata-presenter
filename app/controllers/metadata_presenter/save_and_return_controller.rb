module MetadataPresenter
  class SaveAndReturnController < EngineController
    include Concerns::SaveAndReturn

    helper_method :secret_questions, :confirmed_email

    def show
      @saved_form = SavedForm.new
    end

    def confirmed_email
      email = session['saved_form']['email']
      session['saved_form']['email'] = nil
      session['saved_form']['user_id'] = nil
      session['saved_form']['user_token'] = nil
      session['saved_form']['secret_answer'] = nil
      session['saved_form']['secret_question'] = nil
      session['saved_form']['secret_question_text'] = nil
      session['saved_form']['service_slug'] = nil
      session['saved_form']['service_version'] = nil
      email
    end

    def create
      @saved_form = SavedForm.new
      @saved_form.populate_param_values(saved_form_params)
      @saved_form.secret_question_text = text_for(params['saved_form']['secret_question'])
      @saved_form.secret_question = params['saved_form']['secret_question']
      @saved_form.populate_service_values(service)
      @saved_form.populate_session_values(session)
      @saved_form.service_slug = service_slug
      if @saved_form.valid?
        # put in session until we have confirmed email address
        @saved_form.secret_question = @saved_form.secret_question_text
        session[:saved_form] = @saved_form
        redirect_to '/save/email_confirmation'
      else
        render :show, params: { page_slug: params[:page_slug], status: :unprocessable_entity }
      end
    end

    def email_confirmation
      @saved_form = session[:saved_form]

      if @saved_form
        @email_confirmation = EmailConfirmation.new(@saved_form['email'])
      else
        # we see errors when the session saved form is nil, if this is affecting real users we'd prefer to
        # bump them back to the create step, but we can't easily recreate all the params and we can't cover crawlers hitting the page directly
        redirect_back fallback_location: root_path
      end
    end

    def confirm_email
      @email_confirmation = EmailConfirmation.new(confirmation_params[:email_confirmation])

      if @email_confirmation.valid?
        session['saved_form']['email'] = @email_confirmation.email_confirmation
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

    def save_progress
      destroy_session
    end

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

    private

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

    def service_slug
      @service_slug ||= service_slug_config
    end
  end
end
