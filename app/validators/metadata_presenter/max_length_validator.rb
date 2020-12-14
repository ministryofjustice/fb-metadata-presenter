module MetadataPresenter
  class MaxLengthValidator < BaseValidator
    def invalid_answer?
      answers[component.name].to_s.size > component.validation[schema_key]
    end
  end
end
