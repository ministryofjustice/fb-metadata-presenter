module MetadataPresenter
  class AddressFieldset
    include ActiveModel::Validations
    include ActionView::Helpers

    DEFAULT_COUNTRY = 'United Kingdom'.freeze
    FIELDS = %i[
      address_line_one
      address_line_two
      city
      county
      postcode
      country
    ].freeze

    attr_reader(*FIELDS)

    def initialize(address)
      FIELDS.each do |field|
        next unless address[field.to_s]

        instance_variable_set(:"@#{field}", sanitize(address[field.to_s]))
      end

      @country ||= DEFAULT_COUNTRY
    end

    def to_a
      instance_values.values.compact_blank
    end

    def strip
      instance_values.values.join(', ')
    end
  end
end
