module MetadataPresenter
  class ChangeAnswerController < EngineController
    def create
      session[:return_to_check_you_answer] = true
      redirect_to_page params[:url]
    end
  end
end
