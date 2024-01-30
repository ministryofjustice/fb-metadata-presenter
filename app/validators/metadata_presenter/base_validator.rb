module MetadataPresenter
  class NoDefaultMessage < StandardError; end

  # Abstract base class for validation utilities.
  # Provides an interface for implementing validation from the metadata.
  #
  # @abstract
  #
  # The Base validator expects the subclass to implement only #invalid_answer?
  # as long the conventions are followed:
  #
  # 1. The default metadata for error messages follows the "error.name_of_the_class_without_validator"
  # 2. The class should have the same name as the schema e.g 'required' will lookup for RequiredValidator.
  #
  # On the example below the base validator will look for the custom message
  # on "errors" -> "grogu" -> "any" and if there is none, then will
  # look for the default message on default metadata as "error.grogu".
  #
  # @example Custom validator
  #   class GroguValidator < BaseValidator
  #     def invalid_answer?
  #       user_answer = answers[component.name]
  #
  #       user_answer.to_s == 'Grogu'
  #     end
  #   end
  #
  class BaseValidator
    # @return [MetadataPresenter::PageAnswers] page answers object
    attr_reader :page_answers

    # @return [MetadataPresenter::Component] component object from the metadata
    attr_reader :component

    def initialize(page_answers:, component:)
      @page_answers = page_answers
      @component = component
    end

    def valid?
      return true if allow_blank?

      if invalid_answer?
        error_message = custom_error_message || default_error_message
        page_answers.errors.add(component.id, error_message)
      end

      page_answers.errors.blank?
    end

    # The custom message will be lookup from the schema key on the metadata.
    # Assuming for example that the schema key is 'grogu' then the message
    # will lookup for 'errors.grogu.any'.
    #
    # @return [String] message from the service metadata
    #
    def custom_error_message
      message = component.dig('errors', schema_key, 'any')

      message % error_message_hash if message.present?
    end

    # @return [String] user answer for the specific component
    #
    def user_answer
      page_answers.send(component.name)
    end

    # The default error message will be look using the schema key.
    # Assuming the schema key is 'grogu' then the default message
    # will look for 'error.grogu.value:en' or 'error.grogu.value:cy'.
    #
    # @return [String] returns the default error message
    # @raise [MetadataPresenter::NoDefaultMessage] raises no default message if
    # is not present
    def default_error_message(params = {})
      default_error_message_key = "error.#{schema_key}"
      default_message = Rails.application
                             .config
                             .default_metadata[default_error_message_key]

      if default_message.present?
        default_message[error_key] % error_message_hash.merge(params)
      else
        raise NoDefaultMessage, "No default '#{error_key}' message found for key '#{default_error_message_key}'."
      end
    end

    # Needs to be implemented on the subclass
    #
    # @return [TrueClass] if is invalid
    # @return [FalseClass] if is valid
    #
    def invalid_answer?
      raise NotImplementedError
    end

    # The convention to be looked on the metadata is by the name of the class.
    # E.g the GroguValidator will look for 'grogu' on the metadata.
    # Overwrite this method if the validator doesn't follow the convetions.
    #
    # @return [String] schema key to be looked on the metadata and in the
    # default metadata
    #
    def schema_key
      @schema_key ||= self.class.name.demodulize.gsub('Validator', '').underscore
    end

    # The key to use when retrieving localised error messages.
    # This key will be `value:locale` i.e. `value:en` for English or
    # `value:cy` for Welsh.
    #
    # @return [String] value key to be looked in the default error metadata
    #
    def error_key
      @error_key ||= ['value', I18n.locale].join(':').freeze
    end

    # Error message hash that will be interpolate with the custom message or
    # the default metadata
    #
    # The message could include '%{control}' to add the label name.
    # Or for the GroguValidator will be '%{grogu}' and the value setup in the metadata.
    #
    def error_message_hash
      {
        control: component.humanised_title,
        schema_key.to_sym => validation_value
      }
    end

    # The validation configuration value
    # Override if additional formatting of the value is required
    def validation_value
      component.validation[schema_key]
    end

    # Method signature to be overwrite in the subclass if you do not want to allow
    # blank values. We should not allow blank when performing the required
    # validation.
    #
    # @return [Boolean]
    #
    def allow_blank?
      user_answer.blank? && !self.class.name.demodulize.include?('RequiredValidator')
    end
  end
end
