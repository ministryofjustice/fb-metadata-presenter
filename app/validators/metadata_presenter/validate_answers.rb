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
          "MetadataPresenter::#{key.camelize}Validator".constantize.new(
            **{
              page_answers:,
              component:
            }.merge(autocomplete_param(key))
          )
        end
      }.flatten.compact
    end

    def component_validations(component)
      return [] if component.validation.blank?

      component.validation.compact_blank.keys + additional_validators
    end

    def additional_validators
      %w[catch_all].freeze
    end

    def autocomplete_param(key)
      key == 'autocomplete' ? { autocomplete_items: } : {}
    end
  end
end
