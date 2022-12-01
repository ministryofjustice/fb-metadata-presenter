module MetadataPresenter
  class MaxSizeValidator < UploadValidator
    def error_name
      'invalid.too-large'
    end

    def error_message_hash
      super.merge(
        { schema_key.to_sym => human_max_size }
      )
    end

    def human_max_size
      (component.validation[schema_key].to_f / (1024.0 * 1024.0)).round
    end
  end
end
