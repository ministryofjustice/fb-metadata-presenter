module MetadataPresenter
  class EmailValidator < BaseValidator
    def invalid_answer?
      regex = URI::MailTo::EMAIL_REGEXP
      user_answer.match(regex).nil?
    end
  end
end
