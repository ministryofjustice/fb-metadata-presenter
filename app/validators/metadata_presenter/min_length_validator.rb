module MetadataPresenter
  class MinLengthValidator < BaseValidator
    def invalid_answer?
      user_answer.to_s.size < component.validation[schema_key]
    end
  end
end
