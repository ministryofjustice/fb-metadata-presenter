module MetadataPresenter
  class DefaultMetadata
    def self.[](key)
      Rails.application.config.default_metadata[key].deep_dup
    end
  end
end
