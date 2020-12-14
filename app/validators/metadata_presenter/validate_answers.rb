module MetadataPresenter
  class ValidateAnswers
    attr_reader :page, :components, :answers

    def initialize(page:, answers:)
      @page = page
      @answers = answers
      @components = Array(page.components)
    end

    def valid?
      validators.map { |validator| validator.valid? }.all?
    end

    def invalid?
      !valid?
    end

    def validators
      components.map do |component|
        component_validations(component).map do |key|
          "MetadataPresenter::#{key.classify}Validator".constantize.new(
            page: page,
            answers: answers,
            component: component
          )
        end
      end.compact.flatten
    end

    def component_validations(component)
      return [] if component.validation.blank?
      component.validation.keys
    end
  end
end
