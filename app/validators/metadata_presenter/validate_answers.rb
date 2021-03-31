module MetadataPresenter
  class ValidateAnswers
    attr_reader :page_answers, :components

    def initialize(page_answers, components:)
      @page_answers = page_answers
      @components = Array(components)
    end

    def valid?
      validators.map(&:valid?).all?
    end

    def invalid?
      !valid?
    end

    private

    def validators
      components.map { |component|
        component_validations(component).map do |key|
          "MetadataPresenter::#{key.classify}Validator".constantize.new(
            page_answers: page_answers,
            component: component
          )
        end
      }.compact.flatten
    end

    def component_validations(component)
      return [] if component.validation.blank?

      component.validation.select { |_, value| value.present? }.keys
    end
  end
end
