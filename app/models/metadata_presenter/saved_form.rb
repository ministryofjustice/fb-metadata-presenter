module MetadataPresenter
  class SavedForm
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    validates_with SavedProgressValidator

    attr_accessor :email,
                  :secret_question,
                  :secret_question_text,
                  :secret_answer,
                  :page_slug,
                  :service_slug,
                  :service_version,
                  :user_id,
                  :user_token,
                  :user_data_payload,
                  :attempts,
                  :active,
                  :id,
                  :created_at,
                  :updated_at

    validates :secret_question, :secret_answer, :service_slug, :page_slug, :service_version, :user_id, :user_token, presence: { message: 'Enter an answer for "%{attribute}"' }, allow_blank: false
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
    end

    def populate_service_values(service)
      self.service_slug    = service.service_slug
      self.service_version = service.version_id
    end

    def attributes=(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end

    def attributes
      instance_values
    end
  end
end
