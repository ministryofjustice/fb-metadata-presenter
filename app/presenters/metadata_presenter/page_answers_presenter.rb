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

      if component.type == 'date'
        I18n.l(
          Date.civil(value.year.to_i, value.month.to_i, value.day.to_i),
          format: '%d %B %Y'
        )
      elsif component.type == 'textarea'
        view.simple_format(value, {}, wrapper_tag: 'span')
      else
        value
      end
    end
  end
end
