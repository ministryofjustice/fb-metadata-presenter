module MetadataPresenter
  class EmailConfirmation
    include ActiveModel::Model

    attr_accessor :email_confirmation

    validates_with EmailConfirmationValidator

    def initialize(email)
      self.email_confirmation = email
    end
  end
end
