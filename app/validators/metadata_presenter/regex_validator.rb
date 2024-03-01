module MetadataPresenter
  class RegexValidator < BaseValidator
    def invalid_answer?
      regex = component.validation[schema_key].to_i
      !user_answer.to_s.match(regex)
    end
  end
end