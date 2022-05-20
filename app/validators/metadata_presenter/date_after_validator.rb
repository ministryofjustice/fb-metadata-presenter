module MetadataPresenter
  class DateAfterValidator < DateValidator
    def invalid_answer?
      return if super

      answer_date = "#{user_answer.year}-#{user_answer.month}-#{user_answer.day}"
      Date.parse(answer_date).iso8601 < Date.parse(component.validation[schema_key]).iso8601
    end
  end
end
