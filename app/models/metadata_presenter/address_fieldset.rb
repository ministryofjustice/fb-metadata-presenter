module MetadataPresenter
  class AddressFieldset
    include ActionView::Helpers

    FIELDS = [
      :address_line_one,
      :address_line_two,
      :city,
      :county,
      :postcode,
      :country
    ].freeze

    attr_reader(*FIELDS)

    def initialize(address)
      FIELDS.each do |field|
        instance_variable_set(
          :"@#{field}", sanitize(address[field])
        ) if address[field]
      end
    end

    def present?
      # rubocop:disable Rails/Present
      !blank?
      # rubocop:enable Rails/Present
    end

    def blank?
      address_line_one.blank? || city.blank? || postcode.blank? || country.blank?
    end

    def to_a
      instance_values.values.compact_blank
    end
  end
end
