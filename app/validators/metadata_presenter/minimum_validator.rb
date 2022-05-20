module MetadataPresenter
  class MinimumValidator < NumberValidator
    def invalid_answer?
      return if super

      Float(user_answer, exception: false) < Float(component.validation[schema_key], exception: false)
    end
  end
end
