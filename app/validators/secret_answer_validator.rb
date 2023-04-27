class SecretAnswerValidator < ActiveModel::Validator
  def validate(record)
    if record.secret_answer.strip.downcase != record.recorded_answer.strip.downcase
      record.errors.add(:secret_answer, I18n.t('presenter.save_and_return.validation.answer_not_matched', attempts: record.attempts_remaining))
    end
  end
end
