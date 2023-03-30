module MetadataPresenter
  class EmailConfirmation
    include ActiveModel::Model

    attr_accessor :email_confirmation,
                  :session_email

    validates_with EmailConfirmationValidator

    def initialize; end
    
    def assign_attributes(email_confirmation, session_email)
      @email_confirmation = email_confirmation
      @session_email = session_email
    end
  end
end