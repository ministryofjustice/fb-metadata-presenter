module MetadataPresenter
  module ApplicationHelper
    def main_title(component:, tag: :h1, classes: 'govuk-heading-xl')
      content_tag(tag, class: classes) do
        component.humanised_title
      end
    end

    # Renders html given markdown.
    #
    # @example
    #   <%=to_html '# Some markdown' %>
    #
    def to_html(text)
      Kramdown::Document.new(text).to_html.html_safe
    end

    def default_text(property)
      MetadataPresenter::DefaultText[property]
    end
  end
end
