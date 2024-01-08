module MetadataPresenter
  class RequiredValidator < BaseValidator
    def invalid_answer?
      if component.type == 'multiupload'
        return user_answer[component.id].map(&:blank?).all?
      end

      # Address `required` validation, if needed, is performed
      # in the `AddressValidator` class
      return false if component.type == 'address'

      user_answer.blank?
    end
  end
end
