module MetadataPresenter
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

    delegate :components, to: :page

    def respond_to_missing?(method_name, _include_private = false)
      method_name.to_s.in?(components.map(&:id))
    end

    def method_missing(method_name, *_args)
      component = components.find { |c| c.id == method_name.to_s }

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
        answers["#{component_id}(#{segment})"]
      end
    end

    private

    attr_reader :page, :answers
  end
end
