class SavedProgressValidator < ActiveModel::Validator
  def validate(record)
    regex = URI::MailTo::EMAIL_REGEXP
    if record.email.match(regex).nil?
      record.errors.add(:email, I18n.t('presenter.save_and_return.validation.email'))
    end

    if record.secret_answer.length > 100
      record.errors.add(:secret_answer, I18n.t('presenter.save_and_return.validation.answer_too_long', attribute: 'Secret answer'))
    end
  end
end
