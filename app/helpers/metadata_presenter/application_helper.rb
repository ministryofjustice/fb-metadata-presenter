require 'govspeak'

module MetadataPresenter
  module ApplicationHelper
    def to_markdown(text)
      (Govspeak::Document.new(text).to_html).html_safe
    end
  end
end
