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

  class PageAnswers
    include ActiveModel::Model
    include ActiveModel::Validations

    def initialize(page, answers)
      @page = page
      @answers = answers
    end

    def validate_answers
      ValidateAnswers.new(self, components: components).valid?
    end

    def components
      page.components
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.in?(components.map(&:id))
    end

    def method_missing(method_name, *args, &block)
      component = components.find { |component| component.id == method_name.to_s }

      if component && component.type == 'date'
        date_answer(component.id)
      else
        answers[method_name.to_s]
      end
    end

    def date_answer(component_id)
      date = raw_date_answer(component_id)

      MetadataPresenter::DateField.new(day: date[0], month: date[1], year: date[2])
    end

    def raw_date_answer(component_id)
      [
        GOVUKDesignSystemFormBuilder::Elements::Date::SEGMENTS[:day],
        GOVUKDesignSystemFormBuilder::Elements::Date::SEGMENTS[:month],
        GOVUKDesignSystemFormBuilder::Elements::Date::SEGMENTS[:year]
      ].map do |segment|
        answers["#{component_id.to_s}(#{segment})"]
      end
    end

    private

    attr_reader :page, :answers
  end
end
