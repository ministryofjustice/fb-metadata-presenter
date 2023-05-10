class EmailConfirmationValidator < ActiveModel::Validator
  def validate(record)
    regex = URI::MailTo::EMAIL_REGEXP
    if record.email_confirmation.match(regex).nil?
      record.errors.add(:email_confirmation, I18n.t('presenter.save_and_return.validation.email'))
    end
  end
end
