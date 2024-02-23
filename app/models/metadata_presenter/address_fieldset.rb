module MetadataPresenter
  class AddressFieldset
    extend ActiveModel::Translation
    include ActiveModel::Validations
    include ActionView::Helpers

    DEFAULT_COUNTRY = 'United Kingdom'.freeze
    FIELDS = %w[
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
        next unless address[field]

        instance_variable_set(:"@#{field}", conform(address[field]))
      end

      @country ||= DEFAULT_COUNTRY
    end

    def to_a
      as_json.values.compact_blank
    end

    def as_json
      super(only: FIELDS)
    end

    def conform(address_field)
      sanitize(address_field, tags: [], attributes: []).strip
    end
  end
end
