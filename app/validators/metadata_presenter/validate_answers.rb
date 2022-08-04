module MetadataPresenter
  class ValidateAnswers
    attr_reader :page_answers, :components, :autocomplete_items

    def initialize(page_answers, components:, autocomplete_items:)
      @page_answers = page_answers
      @components = Array(components)
      @autocomplete_items = autocomplete_items
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
            {
              component: component,
              page_answers: page_answers
            }.merge(autocomplete_param(key))
          )
        end
      }.compact.flatten
    end

    def component_validations(component)
      return [] if component.validation.blank?

      component.validation.select { |_, value| value.present? }.keys
    end

    def autocomplete_param(key)
      key == 'autocomplete_item' ? { autocomplete_items: autocomplete_items } : {}
    end
  end
end
