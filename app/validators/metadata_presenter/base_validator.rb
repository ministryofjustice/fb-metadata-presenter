module MetadataPresenter
  class NoDefaultMessage < StandardError; end

  class BaseValidator
    attr_reader :page, :answers, :component

    def initialize(page:, answers:, component:)
      @page = page
      @answers = answers
      @component = component
    end

    def valid?
      if invalid_answer?
        error_message = custom_error_message || default_error_message
        page.errors.add(component.id, error_message)
      end

      page.errors.blank?
    end

    def custom_error_message
      message = component.dig('errors', schema_key, 'any')

      message % error_message_hash if message.present?
    end

    def default_error_message
      default_error_message_key = "error.#{schema_key}"
      default_message = Rails
                          .application
                          .config
                          .default_metadata[default_error_message_key]

      if default_message.present?
        default_message['value'] % error_message_hash
      else
        raise NoDefaultMessage, "No default message found for key '#{default_error_message_key}'."
      end
    end

    def invalid_answer?
      raise NotImplementedError
    end

    def schema_key
      @schema_key ||= self.class.name.demodulize.gsub('Validator', '').underscore
    end

    def error_message_hash
      {
        control: component.label,
        schema_key.to_sym => component.validation[schema_key]
      }
    end
  end
end
