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
                  :user_token,
                  :user_data_payload,
                  :attemtps,
                  :active
                  
    validates :secret_question, :secret_answer, :service_slug, :page_slug, :service_version, :user_id, :user_token, presence: true
    def initialize; end

    def populate_param_values(params)
      self.email           = params['email']
      self.page_slug       = params['saved_form']['page_slug']
      self.secret_question = params['saved_form']['secret_question']
      self.secret_answer   = params['secret_answer']
    end

    def populate_session_values(session)
      self.user_id           = session[:user_id]
      self.user_token        = session[:user_token]
      self.user_data_payload = session[:user_data]
    end
    
    def populate_service_values(service)
      self.service_slug    = service.service_slug
      self.service_version = service.version_id
    end
  end
end
