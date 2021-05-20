module MetadataPresenter
  class AcceptValidator < UploadValidator
    def error_name
      'accept'
    end
  end
end
