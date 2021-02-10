module MetadataPresenter
  class NumberValidator < BaseValidator
    def invalid_answer?
      Float(user_answer, exception: false).blank?
    end
  end
end
