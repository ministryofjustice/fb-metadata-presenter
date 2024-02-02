Rails.application.config.supported_components =
  ActiveSupport::HashWithIndifferentAccess.new({
    checkanswers: {
      input: %w(),
      content: %w(content)
    },
    confirmation: {
      input: %w(),
      content: %w(content)
    },
    content: {
      input: %w(),
      content: %w(content)
    },
    exit: {
      input: %w(),
      content: %w(content)
    },
    multiplequestions: {
      input: %w(text textarea email number date address radios checkboxes),
      content: %w(content)
    },
    singlequestion: {
      input: %w(text textarea number date address radios checkboxes email upload multiupload autocomplete),
      content: %w(content)
     }
  })
