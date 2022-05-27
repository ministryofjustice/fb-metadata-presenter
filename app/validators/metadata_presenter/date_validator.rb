module MetadataPresenter
  class DateValidator < BaseValidator
    DATE_STRING_VALIDATIONS = %w[date_after date_before].freeze

    def invalid_answer?
      Date.strptime(
        "#{user_answer.year}-#{user_answer.month}-#{user_answer.day}",
        '%Y-%m-%d'
      )

      false
    rescue Date::Error
      true
    end

    def validation_value
      return unless schema_key.in?(DATE_STRING_VALIDATIONS)

      Date.parse(component.validation[schema_key]).strftime('%d %m %Y')
    end
  end
end
