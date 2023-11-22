module MetadataPresenter
  class MultiuploadValidator < BaseUploadValidator
    def invalid_answer?
      user_answer.errors.any? { |error| error.attribute.to_s == error_name }
    end

    def error_name
      'invalid.multiupload'
    end
  end
end
