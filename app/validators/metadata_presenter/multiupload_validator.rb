module MetadataPresenter
  class MultiuploadValidator < BaseValidator
    def invalid_answer?
      # TODO: This should be checking if out of bounds of max files?
      # user_answer.error_name == error_name
      false
    end

    def user_answer
      page_answers.uploaded_files.find do |uploaded_file|
        component.id == uploaded_file.component.id
      end
    end

    def error_message_hash
      {
        control: page_answers.send(component.id)['original_filename'],
        schema_key.to_sym => component.validation[schema_key]
      }
    end
  end
end
