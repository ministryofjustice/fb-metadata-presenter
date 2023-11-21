module MetadataPresenter
  class VirusScanValidator < BaseUploadValidator
    def error_name
      'invalid.virus'
    end
  end
end
