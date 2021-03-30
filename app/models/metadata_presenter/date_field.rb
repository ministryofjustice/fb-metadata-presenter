module MetadataPresenter
  class DateField
    attr_reader :day, :month, :year

    def initialize(day:, month:, year:)
      @day = day
      @month = month
      @year = year
    end

    def present?
      # rubocop:disable Rails/Present
      !blank?
      # rubocop:enable Rails/Present
    end

    def blank?
      @day.blank? || @month.blank? || @year.blank?
    end
  end
end
