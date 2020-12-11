module MetadataPresenter
  class RequiredValidator < BaseValidator
    def valid_answer?(component:, answers:)
      answers[component.name].blank?
    end
  end
end
