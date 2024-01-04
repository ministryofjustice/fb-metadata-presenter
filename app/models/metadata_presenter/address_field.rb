module MetadataPresenter
  class AddressField
    include ActionView::Helpers
    attr_reader :address_line_one, :address_line_two, :city, :county, :postcode, :country

    def initialize(address_field)
      @address_line_one = sanitize(address_field[:address_line_one])
      @address_line_two = sanitize(address_field[:address_line_two])
      @city = sanitize(address_field[:city])
      @county = sanitize(address_field[:county])
      @postcode = sanitize(address_field[:postcode])
      @country = sanitize(address_field[:country])
    end

    def present?
      # rubocop:disable Rails/Present
      !blank?
      # rubocop:enable Rails/Present
    end

    def blank?
      @address_line_one.blank? || @city.blank? || @postcode.blank? || @country.blank?
    end
  end
end
