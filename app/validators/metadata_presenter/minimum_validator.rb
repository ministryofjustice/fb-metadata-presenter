module MetadataPresenter
  class MinimumValidator < BaseValidator
    def invalid_answer?
      Float(user_answer, exception: false) < Float(component.validation[schema_key], exception: false)
    end
  end
end
