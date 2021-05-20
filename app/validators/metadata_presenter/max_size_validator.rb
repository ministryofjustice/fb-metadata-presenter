module MetadataPresenter
  class MaxSizeValidator < BaseValidator
    def invalid_answer?
      user_answer.error_name == 'invalid.too-large'
    end

    def user_answer
      page_answers.uploaded_files.find do |uploaded_file|
        component.id == uploaded_file.component.id
      end
    end
  end
end
