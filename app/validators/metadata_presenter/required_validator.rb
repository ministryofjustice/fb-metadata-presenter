module MetadataPresenter
  class RequiredValidator < BaseValidator
    def invalid_answer?
      answers[component.name].blank?
    end
  end
end
