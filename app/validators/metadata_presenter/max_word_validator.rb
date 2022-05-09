module MetadataPresenter
  class MaxWordValidator < BaseValidator
    include WordCount

    def invalid_answer?
      Float(word_count(user_answer), exception: false) > Float(component.validation[schema_key], exception: false)
    end
  end
end
