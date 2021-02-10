module MetadataPresenter
  class MaxLengthValidator < BaseValidator
    def invalid_answer?
      user_answer.to_s.size > component.validation[schema_key]
    end
  end
end
