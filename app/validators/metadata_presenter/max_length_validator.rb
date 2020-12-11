module MetadataPresenter
  class MaxLengthValidator < BaseValidator
    def valid_answer?(component:, answers:)
      answers[component.name].size > component.validation[schema_key]
    end
  end
end
