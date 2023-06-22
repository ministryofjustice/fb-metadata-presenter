module MetadataPresenter
  class RequiredValidator < BaseValidator
    def invalid_answer?
      if component.type == 'multiupload'
        return user_answer[component.id].map(&:blank?).all?
      end

      user_answer.blank?
    end
  end
end
