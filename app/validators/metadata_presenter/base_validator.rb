module MetadataPresenter
  class NoDefaultMessage < StandardError; end

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
      default_error_message_key = "error.#{schema_key}"
      default_message = Rails
                          .application
                          .config
                          .default_metadata[default_error_message_key]

      if default_message.present?
        default_message['value'] % error_message_hash(component)
      else
        raise NoDefaultMessage, "No default message found for key '#{default_error_message_key}'."
      end
    end

    def valid_answer?(component:, answers:)
      raise NotImplementedError
    end

    def schema_key
      self.class.name.demodulize.gsub('Validator', '').underscore
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
