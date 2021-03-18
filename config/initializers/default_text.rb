Rails.application.config.default_text = JSON.parse(
  File.read(
    MetadataPresenter::Engine.root.join('default_text', 'content.json')
  )
)
