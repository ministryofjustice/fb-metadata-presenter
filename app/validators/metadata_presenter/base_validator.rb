module MetadataPresenter
  class BaseValidator
    attr_reader :page, :answers

    def initialize(page:, answers:)
      @page = page
      @answers = answers
    end

    def valid?
      components_to_validate.each do |component|
        if valid_answer?(component: component, answers: answers)
          error_message = custom_error_message(component) || default_error_message(component)
          page.errors.add(component.id, error_message)
        end
      end

      page.errors.blank?
    end

    def custom_error_message(component)
      message = component.dig('errors', schema_key, 'any')

      message % error_message_hash(component) if message.present?
    end

    def default_error_message(component)
      Rails
        .application
        .config
        .default_metadata["error.#{schema_key}"]['value'] % error_message_hash(component)
    end

    def valid_answer?(component:, answers:)
      raise NotImplementedError
    end

    def schema_key
      raise NotImplementedError
    end

    def error_message_hash(component)
      { control: component.label }
    end

    def components_to_validate
      Array(page.components).select do |component|
        component.validation.present? && component.validation[schema_key].present?
      end
    end
  end
end
