module MetadataPresenter
  class SaveAndReturnController < EngineController
    before_action :check_feature_flag
    helper_method :secret_questions

    def show
      @saved_form = SavedForm.new
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
        render :show, status: :unprocessable_entity
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
        uuid = save_form_progress.body["id"]
        # todo rescue failed POST
        # send_email(uuid, confirmation_params[:email_confirmation])
        redirect_to '/save/progress_saved'
      else
        render :email_confirmation, status: :unprocessable_entity
      end
    end

    def return
      uuid = params[:uuid]
      service_slug = params[:service_slug]

      puts get_saved_progress(uuid)
      

      # byebug
    end

    def secret_questions
      [
        OpenStruct.new(id: 1, name: I18n.t('presenter.save_and_return.secret_questions.one')),
        OpenStruct.new(id: 2, name: I18n.t('presenter.save_and_return.secret_questions.two')),
        OpenStruct.new(id: 3, name: I18n.t('presenter.save_and_return.secret_questions.three'))
      ]
    end

    def text_for(question)
      secret_questions.first { |s| s.id.to_s == question.to_s }.name
    end

    def saved_form_params
      params.permit(
        :email,
        :secret_answer,
        {saved_form: [:page_slug, :secret_question]},
        :authenticity_token,
        :page_slug
      )
    end

    def confirmation_params
      params.permit(
        :email_confirmation,
        :authenticity_token,
      )
    end

    private

    def check_feature_flag
      redirect_to '/' and return if ENV['SAVE_AND_RETURN'] != 'enabled'
    end
  end
end
