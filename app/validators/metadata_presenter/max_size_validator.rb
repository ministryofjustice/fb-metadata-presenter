module MetadataPresenter
  class MaxSizeValidator < UploadValidator
    def error_name
      'invalid.too-large'
    end
  end
end
