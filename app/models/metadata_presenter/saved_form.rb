module MetadataPresenter
  class SavedForm
    include ActiveModel::Model
    validates_with SavedProgressValidator

    attr_accessor :email,
                  :secret_question,
                  :secret_answer,
                  :page_slug,
                  :service_slug,
                  :service_version,
                  :user_id,
                  :user_token
                  
    validates :secret_question, :secret_answer, :service_slug, :page_slug, :service_version, :user_id, :user_token, presence: true
    def initialize; end

    def populate_param_values(params)
      @email           = params['email']
      @page_slug       = params['saved_form']['page_slug']
      @secret_question = params['saved_form']['secret_question']
      @secret_answer   = params['secret_answer']
    end

    def populate_session_values(session)
      @user_id    = session[:user_id]
      @user_token = session[:user_token]
    end
    
    def populate_service_values(service)
      @service_slug    = service.service_slug
      @service_version = service.version_id
    end
  end
end
