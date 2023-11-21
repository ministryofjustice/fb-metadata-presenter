module MetadataPresenter
  class DateValidator < BaseValidator
    DATE_STRING_VALIDATIONS = %w[date_after date_before].freeze
    YEAR_LOWER_BOUND = 1000
    YEAR_UPPER_BOUND = 2099

    def invalid_answer?
      date = Date.civil(
        user_answer.year.to_i, user_answer.month.to_i, user_answer.day.to_i
      )

      # additional validations that `#civil` will not raise as errors
      return true if date.year < YEAR_LOWER_BOUND
      return true if date.year > YEAR_UPPER_BOUND

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
