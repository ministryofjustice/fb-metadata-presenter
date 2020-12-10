module MetadataPresenter
  class MaxLengthValidator < BaseValidator
    def valid_answer?(component:, answers:)
      answers[component.name].size > component.validation['max_length']
    end

    def schema_key
      'max_length'
    end

    def error_message_hash(component)
      {
        control: component.label,
        max_length: component.validation[schema_key]
      }
    end
  end
end
