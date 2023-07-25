module MetadataPresenter
  class MultiuploadValidator < BaseValidator
    def invalid_answer?
      user_answer.errors.any? { |error| error.attribute.to_s == error_name }
    end

    def user_answer
      page_answers.uploaded_files.find do |uploaded_file|
        component.id == uploaded_file.component.id
      end
    end

    def error_message_hash
      {
        control: page_answers.send(component.id)[component.id].last['original_filename'],
        schema_key.to_sym => component.validation[schema_key]
      }
    end

    def error_name
      'invalid.multiupload'
    end
  end
end
