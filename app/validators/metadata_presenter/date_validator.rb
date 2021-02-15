module MetadataPresenter
  class DateValidator < BaseValidator
    def invalid_answer?
      Date.strptime(
        "#{user_answer.year}-#{user_answer.month}-#{user_answer.day}",
        '%Y-%m-%d'
      )

      false
    rescue Date::Error
      true
    end
  end
end
