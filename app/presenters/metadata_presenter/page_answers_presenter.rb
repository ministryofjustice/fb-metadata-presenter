module MetadataPresenter
  class PageAnswersPresenter
    FIRST_ANSWER = 0
    NO_USER_INPUT = %w[page.checkanswers page.confirmation page.content].freeze

    def self.map(view:, pages:, answers:)
      user_input_pages(pages).map { |page|
        Array(page.components).map do |component|
          new(
            view: view,
            component: component,
            page: page,
            answers: answers
          )
        end
      }.reject(&:empty?)
    end

    def self.user_input_pages(pages)
      pages.reject { |page| page.type.in?(NO_USER_INPUT) }
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

    def display_heading?(index)
      page.type == 'page.multiplequestions' && index == FIRST_ANSWER
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
      value.join('<br>').html_safe
    end
  end
end
