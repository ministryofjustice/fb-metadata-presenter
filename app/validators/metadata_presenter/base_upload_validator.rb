module MetadataPresenter
  class BaseUploadValidator < BaseValidator
    def invalid_answer?
      user_answer.error_name == error_name
    end

    def user_answer
      page_answers.uploaded_files.find do |uploaded_file|
        component.id == uploaded_file.component.id
      end
    end

    def error_message_hash
      super.merge(control:)
    end

    private

    def control
      if component.type == 'multiupload'
        page_answers.send(component.id)[component.id].last['original_filename']
      else
        page_answers.send(component.id)['original_filename']
      end
    end
  end
end
