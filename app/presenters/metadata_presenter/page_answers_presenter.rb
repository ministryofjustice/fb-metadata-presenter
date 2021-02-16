module MetadataPresenter
  class PageAnswersPresenter
    def self.map(view:, pages:, answers:)
      pages.map do |page|
        Array(page.components).map do |component|
          new(
            view: view,
            component: component,
            page: page,
            answers: answers
          )
        end
      end.flatten
    end

    attr_reader :view, :component, :page, :answers
    delegate :url, to: :page
    delegate :humanised_title, to: :component

    def initialize(view:, component:, page:, answers:)
      @view = view
      @component = component
      @page = page
      @answers = answers

      @page_answers = PageAnswers.new(page, answers)
    end

    def answer
      value = @page_answers.send(component.id)

      return '' if value.blank?
      if self.class.private_method_defined?(component.type.to_sym)
        send(component.type.to_sym, value)
      else
        value
      end
    end

    private

    def date(value)
      I18n.l(
        Date.civil(value.year.to_i, value.month.to_i, value.day.to_i),
        format: '%d %B %Y'
      )
    end

    def textarea(value)
      view.simple_format(value, {}, wrapper_tag: 'span')
    end

    def checkboxes(value)
      value.reject(&:blank?).join("<br>").html_safe
    end
  end
end
