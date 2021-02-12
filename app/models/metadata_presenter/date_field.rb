module MetadataPresenter
  class DateField
    attr_reader :day, :month, :year

    def initialize(day:, month:, year:)
      @day = day
      @month = month
      @year = year
    end

    def present?
      !blank?
    end

    def blank?
      @day.blank? || @month.blank? || @year.blank?
    end
  end
end
