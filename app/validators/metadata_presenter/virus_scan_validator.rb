module MetadataPresenter
  class VirusScanValidator < UploadValidator
    def error_name
      'invalid.virus'
    end
  end
end
