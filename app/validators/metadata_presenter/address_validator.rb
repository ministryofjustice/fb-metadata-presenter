module MetadataPresenter
  class AddressValidator < BaseValidator
    REQUIRED_FIELDS = %i[
      address_line_one
      city
      postcode
      country
    ].freeze

    OPTIONAL_FIELDS = %i[
      address_line_two
      county
    ].freeze

    def valid?
      return true if allow_blank?

      validate_required_fields
      # TODO: validate_postcode

      user_answer.errors.empty?
    end

    private

    def allow_blank?
      component.validation.compact_blank.keys.exclude?('required')
    end

    def error_message
      custom_error_message || default_error_message
    end

    def validate_required_fields
      REQUIRED_FIELDS.each { |field| add_error_if_blank(field) }
    end

    def add_error_if_blank(field)
      if user_answer.send(field).blank?
        page_answers.errors.add([component.id, field].join('.'), :blank)
        user_answer.errors.add(field, :blank)
      end
    end
  end
end
