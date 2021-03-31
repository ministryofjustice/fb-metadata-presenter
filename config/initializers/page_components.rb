Rails.application.config.page_components =
  ActiveSupport::HashWithIndifferentAccess.new({
    checkanswers: {
      input_components: %w(),
      content_components: %w(content)
    },
    confirmation: {
      input_components: %w(),
      content_components: %w(content)
    },
    content: {
      input_components: %w(),
      content_components: %w(content)
    },
    multiplequestions: {
      input_components: %w(text textarea number date radios checkboxes),
      content_components: %w(content)
    }
  })
