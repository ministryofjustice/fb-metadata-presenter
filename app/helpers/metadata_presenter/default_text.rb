module MetadataPresenter
  class DefaultText
    def self.[](property)
      Rails.application.config.default_text[property.to_s]
    end
  end
end
