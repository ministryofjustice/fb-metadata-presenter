module MetadataPresenter
  class MaxFilesValidator < NumberValidator
    def invalid_answer?
      return if super

      # byebug
      Float(user_answer, exception: false) > Float(component.validation[schema_key], exception: false)
    end
  end
end
