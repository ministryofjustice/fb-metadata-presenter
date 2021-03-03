module MetadataPresenter
  module ApplicationHelper
    def main_title(component:, tag: :h1, classes: 'govuk-heading-xl')
      if component.legend.present?
        content_tag(:legend, class: 'govuk-fieldset__legend govuk-fieldset__legend--l') do
          content_tag(tag, class: classes) do
            component.legend
          end
        end
      else
        content_tag(tag, class: classes) do
          component.label
        end
      end
    end

    # Renders markdown given a text.
    #
    # @example
    #   <%=m '# Some markdown' %>
    #
    def m(text)
      (Kramdown::Document.new(text).to_html).html_safe
    end
    alias to_markdown m
  end
end
