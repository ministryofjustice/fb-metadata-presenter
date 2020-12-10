module MetadataPresenter
  class ValidateAnswers
    attr_reader :page, :components, :answers

    def initialize(page:, answers:)
      @page = page
      @answers = answers
      @components = Array(page.components)
    end

    def valid?
      validators.all? do |validator|
        validator.new(page: page, answers: answers).valid?
      end
    end

    def invalid?
      !valid?
    end

    def validators
      validations = components.map do |component|
        component.validation&.keys
      end.compact.flatten

      validations.map do |validation|
        "MetadataPresenter::#{validation.classify}Validator".constantize
      end
    end
  end
end
