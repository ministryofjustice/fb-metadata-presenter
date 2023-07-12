module MetadataPresenter
  class AcceptValidator < UploadValidator
    def error_name
      'accept'
    end

    def error_message_hash
      if component.type == 'multiupload'
        {
          control: page_answers.send(component.id)[component.id].last['original_filename'],
          schema_key.to_sym => component.validation[schema_key]
        }
      else
        super
      end
    end
  end
end
