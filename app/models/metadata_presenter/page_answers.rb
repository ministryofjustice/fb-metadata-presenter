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

    def components
      page.components
    end

    def respond_to_missing?(method_name, include_private = false)
      answers[method_name.to_s].present?
    end

    def method_missing(method_name, *args, &block)
      answers[method_name.to_s]
    end

    private

    attr_reader :page, :answers
  end
end
