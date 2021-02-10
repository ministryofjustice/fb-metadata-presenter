module MetadataPresenter
  class RequiredValidator < BaseValidator
    def invalid_answer?
      user_answer.blank?
    end
  end
end
