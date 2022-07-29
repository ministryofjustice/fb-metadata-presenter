module MetadataPresenter
  class PageAnswersPresenter
    FIRST_ANSWER = 0
    NO_USER_INPUT = %w[
      page.checkanswers
      page.confirmation
      page.content
      page.start
    ].freeze

    def self.map(view:, pages:, answers:)
      user_input_pages(pages).map { |page|
        Array(page.supported_components_by_type(:input)).map do |component|
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
      multiplequestions_page? && index == FIRST_ANSWER
    end

    def last_multiple_question?(index, presenters_count_for_page)
      multiplequestions_page? && index == presenters_count_for_page - 1
    end

    private

    def multiplequestions_page?
      page.type == 'page.multiplequestions'
    end

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

    def upload(file_hash)
      file_hash['original_filename']
    end

    def autocomplete(value)
      JSON.parse(value)['text']
    end
  end
end
