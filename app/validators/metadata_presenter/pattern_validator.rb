module MetadataPresenter
  class PatternValidator < BaseValidator
    def invalid_answer?
      regex = component.validation[schema_key]
      !user_answer.to_s.match(regex)
    end
  end
end
