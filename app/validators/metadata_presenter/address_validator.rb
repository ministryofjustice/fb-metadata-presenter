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

      user_answer.errors.empty?
    end

    private

    def allow_blank?
      component.validation.compact_blank.keys.exclude?('required')
    end

    def validate_required_fields
      REQUIRED_FIELDS.each { |field| add_error_if_blank(field) }
    end

    def add_error_if_blank(field)
      if user_answer.send(field).blank?
        error_message = default_error_message(field: translated_field(field))

        page_answers.errors.add([component.id, field].join('.'), error_message)
        user_answer.errors.add(field, error_message)
      end
    end

    def translated_field(field)
      MetadataPresenter::AddressFieldset.human_attribute_name(field).downcase
    end
  end
end
