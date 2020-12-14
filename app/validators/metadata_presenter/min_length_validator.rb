module MetadataPresenter
  class MinLengthValidator < BaseValidator
    def invalid_answer?
      answers[component.name].size < component.validation[schema_key]
    end
  end
end
