class EmailConfirmationValidator < ActiveModel::Validator
  def validate(record)
    if record.email_confirmation != record.session_email
      record.errors.add(:email_confirmation, I18n.t('presenter.save_and_return.validation.email_not_matched'))
    end
  end
end