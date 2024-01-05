module MetadataPresenter
  class AddressField
    include ActionView::Helpers
    attr_reader :address_line_one, :address_line_two, :city, :county, :postcode, :country

    def initialize(address_field)
      if address_field
        @address_line_one = sanitize(address_field[:address_line_one])
        @address_line_two = sanitize(address_field.fetch(:address_line_two, ''))
        @city = sanitize(address_field[:city])
        @county = sanitize(address_field.fetch(:county, ''))
        @postcode = sanitize(address_field[:postcode])
        @country = sanitize(address_field[:country])
      else
        @address_line_one = ''
        @address_line_two  = ''
        @city  = ''
        @county  = ''
        @postcode  = ''
        @country  = ''
      end
    end

    def present?
      # rubocop:disable Rails/Present
      !blank?
      # rubocop:enable Rails/Present
    end

    def blank?
      @address_line_one.blank? || @city.blank? || @postcode.blank? || @country.blank?
    end

    def to_s
      "#{@address_line_one}\n#{@address_line_two}\n#{@city}\n#{@county}\n#{@postcode}\n#{@country}\n"
    end
  end
end
