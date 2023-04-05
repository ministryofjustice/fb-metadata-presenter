class SavedProgressValidator < ActiveModel::Validator
  def validate(record)
    regex = URI::MailTo::EMAIL_REGEXP
    if record.email.match(regex).nil?
      record.errors.add(:email, I18n.t('presenter.save_and_return.validation.email'))
    end
  end
end
