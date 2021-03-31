module MetadataPresenter
  module ApplicationHelper
    def main_title(component:, tag: :h1, classes: 'govuk-heading-xl')
      content_tag(tag, class: classes) do
        component.humanised_title
      end
    end

    # Renders markdown given a text.
    #
    # @example
    #   <%=m '# Some markdown' %>
    #
    def m(text)
      Kramdown::Document.new(text).to_html.html_safe
    end
    alias_method :to_markdown, :m

    def default_text(property)
      MetadataPresenter::DefaultText[property]
    end
  end
end
