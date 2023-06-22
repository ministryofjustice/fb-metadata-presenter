require 'govspeak'

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
      Govspeak::Document.new(text).to_html.html_safe
    end

    def default_text(property)
      MetadataPresenter::DefaultText[property]
    end

    def default_title(component_type)
      MetadataPresenter::DefaultMetadata["component.#{component_type}"]&.[]('label') ||
        MetadataPresenter::DefaultMetadata["component.#{component_type}"]&.[]('legend')
    end

    def default_item_title(component_type)
      return unless %w[checkboxes radios].include?(component_type)

      MetadataPresenter::DefaultMetadata["component.#{component_type}"]['items']&.first&.[]('label')
    end
  end
end
