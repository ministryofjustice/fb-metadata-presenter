module MetadataPresenter
  class AuthController < EngineController
    skip_before_action :require_basic_auth
    before_action :check_session_is_authorised

    def show
      @auth_form = AuthForm.new
    end

    def create
      @auth_form = AuthForm.new(auth_params)

      if @auth_form.valid?
        authorised_session!
        redirect_to root_path
      else
        render :show
      end
    end

    private

    def allow_analytics?
      false
    end

    def show_cookie_request?
      false
    end

    def check_session_is_authorised
      redirect_to root_path if session_authorised?
    end

    def auth_params
      params.require(:auth_form).permit(
        :username, :password
      )
    end
  end
end
